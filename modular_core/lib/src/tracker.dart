// ignore_for_file: avoid_print

part of '../../modular_core.dart';

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
  FutureOr<ModularRoute?> findRoute(
    String path, {
    dynamic data,
    String schema = '',
  });

  /// Reports whether a route will leave the route context.
  /// This is important to call automatic dispose of the entire context.
  void reportPopRoute(ModularRoute route);

  /// It informs you that a new route has been found and that
  /// it needs its dependent BindContexts started as well.
  void reportPushRoute(ModularRoute route);

  /// Responsible for starting the app.
  /// It should only be called once, but it should be the
  /// first method to be called before a route or bind lookup.
  void runApp(Module module, [String initialRoutePath = '/']);

  /// Add a Module to Injection System.<br>
  /// Use Tracker.unbindModule to remove registers;
  void bindModule(Module module, [String? tag]);

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
  final _importedInjector = <String, AutoInjector>{};

  Module? _nullableModule;
  @override
  Module get module {
    if (_nullableModule != null) {
      return _nullableModule!;
    }

    throw const TrackerNotInitiated('Execute Tracker.runApp()');
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
  void runApp(Module module, [String initialRoutePath = '/']) {
    _nullableModule = module;
    _disposeTags[module.runtimeType] = [initialRoutePath];
    bindModule(module);
    addRoutes(module);
  }

  @override
  FutureOr<ModularRoute?> findRoute(
    String path, {
    dynamic data,
    String schema = '',
  }) async {
    final uri = _resolverPath(path);
    final modularKey = ModularKey(schema: schema, name: uri.path);

    ModularRoute? route;
    var params = <String, String>{};

    for (final key in routeMap.keys) {
      final uriCandidate = Uri.parse(key.name);
      if (uriCandidate.path == uri.path) {
        final candidate = routeMap[key];
        if (key.copyWith(name: uri.path) == modularKey) {
          route = candidate;
          break;
        }
      }
      if (uriCandidate.pathSegments.length != uri.pathSegments.length //
          &&
          !uriCandidate.path.contains('**')) {
        continue;
      }

      if (!(uriCandidate.path.contains(':') //
          ||
          uriCandidate.path.contains('**'))) {
        continue;
      }

      final result = _extractParams(uriCandidate, uri);
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

    for (final middleware in route.middlewares) {
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

    for (final key in _disposeTags.keys) {
      final moduleTags = _disposeTags[key]!;

      if (moduleTags.isEmpty) {
        continue;
      }

      moduleTags.removeWhere((element) => element.startsWith(tag));
      if (tag.characters.last == '/') {
        moduleTags.remove('$tag/'.replaceAll('//', ''));
      }

      if (moduleTags.isEmpty) {
        unbindModule(key.toString());
      }
    }
  }

  void _removeRegisters(String tag) {
    injector.disposeInjectorByTag(tag, _disposeInstance);

    printResolverFunc?.call('-- $tag DISPOSED');
  }

  void _disposeInstance(dynamic instance) {
    if (instance is Disposable) {
      instance.dispose();
    }
  }

  @override
  void reportPushRoute(ModularRoute route) {
    for (final module in [...route.innerModules.values, module]) {
      final key = module.runtimeType;
      if (_disposeTags[key]!.isEmpty) {
        bindModule(module);
        printResolverFunc?.call('-- ${module.runtimeType} INITIALIZED');
      }
      final routeUri = route.uri.toString();
      if (_disposeTags[key]!.isNotEmpty && routeUri != '/') {
        if (_disposeTags[key]!.contains(routeUri)) {
          continue;
        }
      }
      _disposeTags[key]!.add(routeUri);
    }
  }

  @override
  void bindModule(Module module, [String? tag]) {
    final newInjector = _createInjector(module, tag);

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

    final regExp = RegExp('^$settledUrl\$');
    final result = regExp.firstMatch(match.path);

    if (result != null) {
      final params = <String, String>{};
      for (final name in result.groupNames) {
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
      part = part.contains(':') ? '(?<${part.substring(1)}>.*)' : part;
      newUrl.add(part);
    }
    return newUrl.join('/');
  }

  AutoInjector _createExportedInjector(Module importedModule) {
    final importTag = importedModule.runtimeType.toString();
    late AutoInjector exportedInject;
    if (!_importedInjector.containsKey(importTag)) {
      exportedInject = _createInjector(importedModule, '${importTag}_Imported');
      importedModule.exportedBinds(exportedInject);
      _importedInjector[importTag] = exportedInject;
    } else {
      exportedInject = _importedInjector[importTag]!;
    }

    return exportedInject;
  }

  AutoInjector _createInjector(Module module, [String? tag]) {
    final newInjector = AutoInjector(tag: tag ?? module.runtimeType.toString());
    for (final importedModule in module.imports) {
      final exportedInject = _createExportedInjector(importedModule);
      newInjector.addInjector(exportedInject);
    }

    module.binds(newInjector);
    return newInjector;
  }

  void addRoutes(Module module) {
    final manager = RouteManager();
    module.routes(manager);
    final routes = manager._routes;

    final _routeMap = <ModularKey, ModularRoute>{};
    for (final route in routes) {
      _routeMap.addAll(_assembleRoute(route));
    }

    final _odernatedMap = <ModularKey, ModularRoute>{};
    for (final key in _orderRouteKeys(_routeMap.keys)) {
      _odernatedMap[key] = _routeMap[key]!;
    }

    routeMap.addAll(_odernatedMap);
  }

  Map<ModularKey, ModularRoute> _assembleRoute(ModularRoute route) {
    final map = <ModularKey, ModularRoute>{};

    if (route.module == null) {
      map[route.key] = route;
      map.addAll(_addChildren(route));
    } else {
      map.addAll(_addModule(route));
    }

    return map;
  }

  List<ModularKey> _orderRouteKeys(Iterable<ModularKey> keys) {
    final ordenatekeys = <ModularKey>[...keys];
    ordenatekeys.sort((preview, actual) {
      if (preview.name.contains('/:') && !actual.name.contains('**')) {
        return 1;
      }

      if (preview.name.contains('**')) {
        final c =
            actual.name.split('/').length > preview.name.split('/').length;
        if (!actual.name.contains('**') || c) {
          return 1;
        }
      }

      return 0;
    });
    return ordenatekeys;
  }

  Map<ModularKey, ModularRoute> _addModule(ModularRoute route) {
    final map = <ModularKey, ModularRoute>{};
    final module = route.module!;
    final manager = RouteManager();
    module.routes(manager);
    final routes = manager._routes;
    _disposeTags[module.runtimeType] = [];
    for (var child in routes) {
      child = child.addParent(route);
      child = child.copyWith(
        innerModules: {
          ...child.innerModules,
          module.runtimeType: module,
        },
        parent: route.parent,
      );
      map.addAll(_assembleRoute(child));
    }

    return map;
  }

  Map<ModularKey, ModularRoute> _addChildren(ModularRoute route) {
    final map = <ModularKey, ModularRoute>{};

    for (var child in route.children) {
      child = child.addParent(route);
      map.addAll(_assembleRoute(child));
    }

    return map;
  }

  @override
  void finishApp() {
    injector.disposeRecursive();
    routeMap.clear();
    _disposeTags.clear();
    _nullableModule = null;
  }

  @override
  void setArguments(ModularArguments args) => _arguments = args;
}
