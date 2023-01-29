import 'dart:async';

import 'package:auto_injector/auto_injector.dart';
import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import '../di/bind.dart';
import '../di/disposable.dart';
import '../errors/errors.dart';
import '../module/module.dart';
import 'arguments.dart';
import 'route.dart';

abstract class Tracker {
  /// Service Injector instancia
  AutoInjector get injector;

  /// Initial Module
  Module get module;

  ModularArguments get arguments;

  void setArguments(ModularArguments arguments);

  String get currentPath;

  factory Tracker(AutoInjector injector) => _Tracker(injector);

  /// Searches for a route by name or context throughout the tree.
  FutureOr<ModularRoute?> findRoute(String path, {dynamic data, String schema = ''});

  /// Reports whether a route will leave the route context. This is important to call automatic dispose of the entire context.
  void reportPopRoute(ModularRoute route);

  /// It informs you that a new route has been found and that it needs its dependent BindContexts started as well.
  void reportPushRoute(ModularRoute route);

  /// Responsible for starting the app.
  /// It should only be called once, but it should be the first method to be called before a route or bind lookup.
  void runApp(Module module, [String initialRoutePath = '/']);

  /// Add a Module to Injection System.<br>
  /// Use Tracker.unbindModule to remove registers;
  void bindModule(Module module);

  /// Remove registers manually;
  void unbindModule(String moduleName);

  /// Finishes all trees.
  void finishApp();

  /// dispose instance
  bool dispose<B>();
}

class _Tracker implements Tracker {
  @override
  final AutoInjector injector;

  final _disposeTags = <Type, List<String>>{};

  Module? _nullableModule;
  @override
  Module get module {
    if (_nullableModule != null) {
      return _nullableModule!;
    }

    throw TrackerNotInitiated('Execute Tracker.runApp()');
  }

  @visibleForTesting
  final routeMap = <ModularKey, ModularRoute>{};

  _Tracker(this.injector);

  var _arguments = ModularArguments.empty();

  @override
  ModularArguments get arguments => _arguments;

  @override
  String get currentPath => arguments.uri.toString();

  @override
  FutureOr<ModularRoute?> findRoute(String path, {dynamic data, String schema = ''}) async {
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
      if (uriCandidate.pathSegments.length != uri.pathSegments.length && !uriCandidate.path.contains('**')) {
        continue;
      }

      if (!(uriCandidate.path.contains(':') || uriCandidate.path.contains('**'))) {
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

  @override
  void reportPopRoute(ModularRoute route) {
    final tag = route.uri.toString();

    for (var key in _disposeTags.keys) {
      final moduleTags = _disposeTags[key]!;

      moduleTags.remove(tag);
      if (tag.characters.last == '/') {
        moduleTags.remove('$tag/'.replaceAll('//', ''));
      }

      if (moduleTags.isEmpty) {
        unbindModule(key.toString());
      }
    }
  }

  void _removeRegisters(String tag) {
    injector.uncommit();

    injector.disposeSingletonsByTag(
      tag,
      onRemoved: _disposeInstance,
    );
    injector.removeByTag(tag);
    injector.commit();

    print("-- $tag DISPOSED");
  }

  void _disposeInstance(dynamic instance) {
    if (instance is Disposable) {
      instance.dispose();
    }
  }

  @override
  void reportPushRoute(ModularRoute route) {
    for (var module in [...route.innerModules.values, module]) {
      final key = module.runtimeType;
      if (_disposeTags[key]!.isEmpty) {
        bindModule(module);
        print("-- ${module.runtimeType} INITIALIZED");
      }
      _disposeTags[key]!.add(route.uri.toString());
    }
  }

  @override
  void bindModule(Module module) {
    final newInjector = _createInjector(module);

    injector.uncommit();
    injector.addInjector(newInjector);
    injector.commit();
  }

  @override
  void unbindModule(String moduleName) {
    _removeRegisters(moduleName);
  }

  @override
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

  @override
  void runApp(Module module, [String initialRoutePath = '/']) {
    _nullableModule = module;
    _disposeTags[module.runtimeType] = [initialRoutePath];
    bindModule(module);
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
      bind.includeInjector(injector);
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
        if (!actual.name.contains('**') || actual.name.split('/').length > preview.name.split('/').length) {
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
      child = child.copyWith(innerModules: {module.runtimeType: module});
      child = child.addParent(route);
      map.addAll(_assembleRoute(child));
    }

    return map;
  }

  Map<ModularKey, ModularRoute> _addChildren(ModularRoute route) {
    final Map<ModularKey, ModularRoute> map = {};

    for (var child in route.children) {
      child = child.addParent(route);
      map.addAll(_assembleRoute(child));
    }

    return map;
  }

  @override
  void finishApp() {
    injector.removeAll();
    routeMap.clear();
    _disposeTags.clear();
    _nullableModule = null;
  }

  @override
  void setArguments(ModularArguments args) => _arguments = args;
}
