import 'dart:async';

import 'package:auto_injector/auto_injector.dart';
import 'package:characters/characters.dart';
import 'package:meta/meta.dart';
import 'package:modular_core/src/di/disposable.dart';

import 'core_module.dart';

class Tracker {
  final AutoInjector injector;

  final _disposeTags = <Type, List<String>>{};

  Module? _nullableModule;
  Module get module {
    if (_nullableModule != null) {
      return _nullableModule!;
    }

    throw TrackerNotInitiated('Execute Tracker.runApp()');
  }

  @visibleForTesting
  final routeMap = <ModularKey, ModularRoute>{};

  Tracker(this.injector);

  var _arguments = ModularArguments.empty();

  ModularArguments get arguments => _arguments;

  String get currentPath => arguments.uri.toString();

  FutureOr<ModularRoute?> findRoute(String path,
      {dynamic data, String schema = ''}) async {
    var uri = _resolverPath(path);
    final modularKey = ModularKey(schema: schema, name: uri.path);

    ModularRoute? route;
    var params = <String, String>{};

    for (var key in routeMap.keys) {
      var uriCandidate = Uri.parse(key.name);
      if (uriCandidate.path == uri.path) {
        final candidate = routeMap[key];
        if (key.copyWith(name: uri.path) == modularKey) {
          route = candidate;
          break;
        }
      }
      if (uriCandidate.pathSegments.length != uri.pathSegments.length &&
          !uriCandidate.path.contains('**')) {
        continue;
      }

      if (!(uriCandidate.path.contains(':') ||
          uriCandidate.path.contains('**'))) {
        continue;
      }

      var result = _extractParams(uriCandidate, uri);
      if (result != null) {
        final candidate = routeMap[key];
        if (key.copyWith(name: uri.path) == modularKey) {
          route = candidate;
          params = result;
          break;
        }
      }
    }

    if (route == null) return null;

    route = route.copyWith(uri: uri);

    for (var middleware in route.middlewares) {
      route = await middleware.pre(route!);
      if (route == null) {
        break;
      }
    }

    if (route == null) return null;

    _arguments = ModularArguments(uri: uri, data: data, params: params);

    return route;
  }

  void reportPopRoute(ModularRoute route) {
    final tag = route.uri.toString();

    for (var key in _disposeTags.keys) {
      final moduleTags = _disposeTags[key]!;

      moduleTags.remove(tag);
      if (tag.characters.last == '/') {
        moduleTags.remove('$tag/'.replaceAll('//', ''));
      }

      if (moduleTags.isEmpty) {
        _removeRegisters(key.toString());
      }
    }
  }

  void _removeRegisters(String tag) {
    injector.disposeSingletonsByTag(
      tag,
      onRemoved: _disposeInstance,
    );
    injector.removeByTag(tag);
    print("-- $tag DISPOSED");
  }

  void _disposeInstance(dynamic instance) {
    if (instance is Disposable) {
      instance.dispose();
    }
  }

  void reportPushRoute(ModularRoute route) {
    for (var module in [...route.innerModules.values, module]) {
      final key = module.runtimeType;
      if (_disposeTags[key]!.isEmpty) {
        final newInjector = _createInjector(module);
        injector.addInjector(newInjector);
        print("-- ${module.runtimeType} INITIALIZED");
      }
      _disposeTags[key]!.add(route.uri.toString());
    }
    final newInjector = _createInjector(module);
    injector.addInjector(newInjector);
  }

  bool dispose<B>() {
    final dead = injector.disposeSingleton<B>();
    _disposeInstance(dead);
    return dead != null;
  }

  Uri _resolverPath(String path) {
    return arguments.uri.resolve(path);
  }

  Map<String, String>? _extractParams(Uri candidate, Uri match) {
    final settledUrl = _processUrl(candidate.path);

    final regExp = RegExp("^$settledUrl\$", caseSensitive: true);
    final result = regExp.firstMatch(match.path);

    if (result != null) {
      final params = <String, String>{};
      for (var name in result.groupNames) {
        params[name] = result.namedGroup(name)!;
      }
      return params;
    } else {
      return null;
    }
  }

  String _processUrl(String url) {
    if (url.endsWith('**')) {
      return url.replaceFirst('**', '(?<w>.*)');
    }

    final newUrl = <String>[];
    for (var part in url.split('/')) {
      part = part.contains(":") ? "(?<${part.substring(1)}>.*)" : part;
      newUrl.add(part);
    }
    return newUrl.join("/");
  }

  void runApp(Module module) {
    _nullableModule = module;

    final newInjector = _createInjector(module);
    injector.addInjector(newInjector);
    addRoutes(module);
  }

  AutoInjector _createInjector(Module module) {
    final newInjector = AutoInjector(tag: module.runtimeType.toString());
    _addBinds(module.binds, newInjector);

    for (var importedModule in module.imports) {
      _addExportedBinds(importedModule, newInjector);
    }

    return newInjector;
  }

  void _addBinds(List<Bind> binds, AutoInjector injector) {
    for (var bind in binds) {
      if (bind is SingletonBind) {
        injector.addSingleton(bind.constructor);
      } else if (bind is LazySingletonBind) {
        injector.addLazySingleton(bind.constructor);
      } else if (bind is InstanceBind) {
        injector.addInstance(bind.constructor);
      } else if (bind is FactoryBind) {
        injector.add(bind.constructor);
      }
    }
  }

  void _addExportedBinds(Module module, AutoInjector injector) {
    _addBinds(module.exportedBinds, injector);
    for (var importedModule in module.imports) {
      _addExportedBinds(importedModule, injector);
    }
  }

  void addRoutes(Module module) {
    final routes = module.routes;

    final _routeMap = <ModularKey, ModularRoute>{};
    for (var route in routes) {
      _routeMap.addAll(_assembleRoute(route));
    }

    final _odernatedMap = <ModularKey, ModularRoute>{};
    for (var key in _orderRouteKeys(_routeMap.keys)) {
      _odernatedMap[key] = _routeMap[key]!;
    }

    routeMap.addAll(_odernatedMap);
  }

  Map<ModularKey, ModularRoute> _assembleRoute(ModularRoute route) {
    final Map<ModularKey, ModularRoute> map = {};

    if (route.module == null) {
      map[route.key] = route;
      map.addAll(_addChildren(route));
    } else {
      map.addAll(_addModule(route));
    }

    return map;
  }

  List<ModularKey> _orderRouteKeys(Iterable<ModularKey> keys) {
    List<ModularKey> ordenatekeys = [...keys];
    ordenatekeys.sort((preview, actual) {
      if (preview.name.contains('/:') && !actual.name.contains('**')) {
        return 1;
      }

      if (preview.name.contains('**')) {
        if (!actual.name.contains('**')) {
          return 1;
        } else if (actual.name.split('/').length >
            preview.name.split('/').length) {
          return 1;
        }
      }

      return 0;
    });
    return ordenatekeys;
  }

  Map<ModularKey, ModularRoute> _addModule(ModularRoute route) {
    final Map<ModularKey, ModularRoute> map = {};
    final module = route.module!;
    _disposeTags[module.runtimeType] = [];
    for (var child in module.routes) {
      child = child.copyWith(
        innerModules: {module.runtimeType: module},
        parent: route.parent,
      );
      child = _copy(route, child);
      map.addAll(_assembleRoute(child));
    }

    return map;
  }

  Map<ModularKey, ModularRoute> _addChildren(ModularRoute route) {
    final Map<ModularKey, ModularRoute> map = {};

    for (var child in route.children) {
      child = child.copyWith(parent: route.name);
      child = _copy(route, child);
      map.addAll(_assembleRoute(child));
    }

    return map;
  }

  ModularRoute _copy(ModularRoute parent, ModularRoute route) {
    final newName = '${parent.name}${route.name}'.replaceFirst('//', '/');
    return route.copyWith(
      name: newName,
      middlewares: [
        ...parent.middlewares,
        ...route.middlewares,
      ],
      innerModules: {
        ...parent.innerModules,
        ...route.innerModules,
      },
    );
  }

  void finishApp() {
    injector.removeAll();
    routeMap.clear();
    _nullableModule = null;
  }

  void setArguments(ModularArguments args) => _arguments = args;
}

class TrackerNotInitiated extends ModularError {
  const TrackerNotInitiated(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Object that clusters all arguments and parameters retrieved or produced during a route search.
class ModularArguments {
  /// It retrieves parameters after consulting a dynamic route. If it is not a dynamic route the object will be an empty Map.
  /// ex: /product/:id  ->  /product/1
  /// Modular.args.params['id']; -> '1'
  final Map<String, dynamic> params;

  /// Uri of current route.
  final Uri uri;

  /// Retrieved from a direct input of arguments from the navigation system itself.
  /// ex: Modular.to.navigate('/product', arguments: Products());
  /// Modular.args.data;  -> Product();
  final dynamic data;

  const ModularArguments(
      {this.params = const {}, this.data, required this.uri});

  ModularArguments copyWith(
      {Map<String, dynamic>? params, dynamic data, Uri? uri}) {
    return ModularArguments(
      params: params ?? this.params,
      data: data ?? this.data,
      uri: uri ?? this.uri,
    );
  }

  /// The value is the empty string if there is no fragment identifier component.
  String get fragment => uri.fragment;

  /// The URI query split into a map according to the rules specified for FORM post in the HTML 4.01 specification section 17.13.4.
  /// Each key and value in the resulting map has been decoded. If there is no query the empty map is returned.
  /// Keys in the query string that have no value are mapped to the empty string. If a key occurs more than once in the query string, it is mapped to an arbitrary choice of possible value. The [queryParametersAll] getter can provide a map that maps keys to all of their values.
  /// The map and the lists it contains are unmodifiable.
  Map<String, String> get queryParams => uri.queryParameters;

  /// Returns the URI query split into a map according to the rules specified for FORM post in the HTML 4.01 specification section 17.13.4.
  /// Each key and value in the resulting map has been decoded. If there is no query the map is empty.
  /// Keys are mapped to lists of their values. If a key occurs only once, its value is a singleton list. If a key occurs with no value, the empty string is used as the value for that occurrence.
  /// The map and the lists it contains are unmodifiable.
  Map<String, List<String>> get queryParamsAll => uri.queryParametersAll;

  factory ModularArguments.empty() {
    return ModularArguments(uri: Uri.parse('/'));
  }
}

abstract class ModularError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const ModularError(this.message, [this.stackTrace]);

  String _returnStackTrace() =>
      stackTrace != null ? '\n${stackTrace.toString()}' : '';

  @override
  String toString() => '$runtimeType: $message${_returnStackTrace()}';
}
