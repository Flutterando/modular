import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../flutter_modular.dart';
import 'interfaces/child_module.dart';
import 'interfaces/route_guard.dart';
import 'navigator/modular_navigator.dart';
import 'navigator/modular_navigator_interface.dart';
import 'routers/modular_router.dart';
import 'utils/old.dart';

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

class ModularNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route previousRoute) {
    Modular._navigators.forEach((key, value) {
      if (value.currentState != null && key != null) {}
    });
    super.didPop(route, previousRoute);
  }
}

class Modular {
  static const String initialRoute = '/';
  static bool debugMode = !kReleaseMode;
  static bool isCupertino = false;
  static final Map<String, ChildModule> _injectMap = {};
  static ChildModule _initialModule;
  static ModularArguments _args;
  static RouteLink _routeLink;
  static Old _old = Old();
  static Old get old => _old;
  static ModularArguments get args => _args?.copy();
  static IModularNavigator navigatorDelegate;
  static List<String> currentModule = <String>[];
  static Map<String, GlobalKey<NavigatorState>> _navigators =
      <String, GlobalKey<NavigatorState>>{};

  /// Return RouteLink of the current module
  ///
  /// ```
  /// Modular.link;
  /// ```
  static IModularNavigator get link {
    if (navigatorDelegate == null) {
      assert(_navigators.containsKey('app') == true,
          '''Add Modular.navigatorKey in your MaterialApp;

      return MaterialApp(
        navigatorKey: Modular.navigatorKey,
        ...

.
      ''');
    }
    return navigatorDelegate ?? _routeLink?.copy();
  }

  /// Return Modular.navigator
  /// Used for inside RouterOutlet

  static IModularNavigator get navigator {
    return ModularNavigator(_navigators[currentModule.last].currentState);
  }

  /// Add Navigator key for RouterOutlet
  static GlobalKey<NavigatorState> outletNavigatorKey(String path) {
    if (!_navigators.containsKey(path)) {
      _navigators.addAll({path: GlobalKey<NavigatorState>()});
    }
    return _navigators[path];
  }

  /// Remove Navigator key
  static void removeOutletNavigatorKey(String path) {
    if (_navigators.containsKey(path)) {
      _navigators.remove(path);
    }
  }

  /// Add first position app in currentModule
  static void updateCurrentModuleApp() {
    if (Modular.currentModule.contains("app")) {
      Modular.currentModule.remove("app");
    }
    Modular.currentModule.insert(0, "app");
  }

  /// Add last position module in currentModule
  static void updateCurrentModule(String name) {
    if (Modular.currentModule.contains(name)) {
      Modular.currentModule.remove(name);
    }
    Modular.currentModule.add(name);
  }

  /// Return Modular.navigatorKey
  ///
  /// ```
  /// Modular.to;
  /// ```
  static IModularNavigator get to {
    if (navigatorDelegate == null) {
      assert(_navigators.containsKey('app') == true,
          '''Add Modular.navigatorKey in your MaterialApp;

      return MaterialApp(
        navigatorKey: Modular.navigatorKey,
        ...


      ''');
    }
    return navigatorDelegate ??
        ModularNavigator(_navigators['app'].currentState);
  }

  @visibleForTesting
  static void arguments({Map<String, dynamic> params, dynamic data}) {
    _args = ModularArguments(params ?? {}, data);
  }

  static GlobalKey<NavigatorState> get navigatorKey {
    if (!_navigators.containsKey('app')) {
      _navigators.addAll({'app': GlobalKey<NavigatorState>()});
      if (!currentModule.contains("app")) {
        currentModule.add("app");
      }
    }
    return _navigators['app'];
  }

  static void init(ChildModule module) {
    _initialModule = module;
    bindModule(module, "global==");
  }

  @visibleForTesting
  static void bindModule(ChildModule module, [String path]) {
    assert(module != null);
    final name = module.runtimeType.toString();
    if (!_injectMap.containsKey(name)) {
      module.paths.add(path);
      _injectMap[name] = module;
      module.instance();
      _debugPrintModular("-- ${module.runtimeType.toString()} INITIALIZED");
    } else {
      _injectMap[name].paths.add(path);
    }
  }

  static void removeModule(ChildModule module, [String name]) {
    name ??= module.runtimeType.toString();
    if (_injectMap.containsKey(name)) {
      _injectMap[name].cleanInjects();
      _injectMap.remove(name);
      if (_navigators.containsKey(name)) {
        _navigators.remove(name);
        currentModule.remove(name);
      }
    }
  }

  static B get<B>(
      {Map<String, dynamic> params,
      String module,
      List<Type> typesInRequest,
      B defaultValue}) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    typesInRequest ??= [];

    if (module != null) {
      return _getInjectableObject<B>(module,
          params: params, typesInRequest: typesInRequest);
    }

    for (var key in _injectMap.keys) {
      final value = _getInjectableObject<B>(key,
          params: params,
          disableError: true,
          typesInRequest: typesInRequest,
          checkKey: false);
      if (value != null) {
        return value;
      }
    }

    if (defaultValue != null) {
      return defaultValue;
    }

    throw ModularError('${B.toString()} not found');
  }

  static B _getInjectableObject<B>(String tag,
      {Map<String, dynamic> params,
      bool disableError = false,
      List<Type> typesInRequest,
      bool checkKey = true}) {
    B value;
    if (!checkKey) {
      value =
          _injectMap[tag].getBind<B>(params, typesInRequest: typesInRequest);
    } else if (_injectMap.containsKey(tag)) {
      value =
          _injectMap[tag].getBind<B>(params, typesInRequest: typesInRequest);
    }
    if (value == null && !disableError) {
      throw ModularError('${B.toString()} not found in module $tag');
    }

    return value;
  }

  static void dispose<B>([String module]) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    if (module != null) {
      _removeInjectableObject(module);
    } else {
      for (var key in _injectMap.keys) {
        if (_removeInjectableObject<B>(key)) {
          break;
        }
      }
    }
  }

  static bool _removeInjectableObject<B>(String tag) {
    return _injectMap[tag].remove<B>();
  }

  @visibleForTesting
  static String prepareToRegex(String url) {
    final newUrl = <String>[];
    for (var part in url.split('/')) {
      var url = part.contains(":") ? "(.*?)" : part;
      newUrl.add(url);
    }

    return newUrl.join("/");
  }

  @visibleForTesting
  static dynamic convertType(String value) {
    if (int.tryParse(value) != null) {
      return int.parse(value);
    } else if (double.tryParse(value) != null) {
      return double.parse(value);
    } else if (value.toLowerCase() == 'true') {
      return true;
    } else if (value.toLowerCase() == 'false') {
      return false;
    }

    return value;
  }

  @visibleForTesting
  static bool searchRoute(
      ModularRouter router, String routeNamed, String path) {
    if (routeNamed.split('/').length != path.split('/').length) {
      return false;
    }

    if (routeNamed.contains('/:')) {
      final regExp = RegExp(
        "^${prepareToRegex(routeNamed)}\$",
        caseSensitive: true,
      );
      var r = regExp.firstMatch(path);
      if (r != null) {
        final params = <String, String>{};
        var paramPos = 0;
        final routeParts = routeNamed.split('/');
        final pathParts = path.split('/');

        //  print('Match! Processing $path as $routeNamed');

        for (var routePart in routeParts) {
          if (routePart.contains(":")) {
            var paramName = routePart.replaceFirst(':', '');
            if (pathParts[paramPos].isNotEmpty) {
              params[paramName] = pathParts[paramPos];
              routeNamed =
                  routeNamed.replaceFirst(routePart, params[paramName]);
            }
          }
          paramPos++;
        }

        // print('Result processed $path as $routeNamed');

        if (routeNamed != path) {
          router.params = null;
          return false;
        }

        router.params = params;
        return true;
      }

      router.params = null;
      return false;
    }

    return routeNamed == path;
  }

  static RouteGuard _verifyGuard(List<RouteGuard> guards, String path) {
    RouteGuard guard;
    var realGuards = guards ?? [];
    guard = realGuards.length == 0
        ? null
        : guards.firstWhere((guard) => guard.canActivate(path),
            orElse: () => null);

    realGuards
        .expand((c) => c.executors)
        .forEach((c) => c.onGuarded(path, isActive: guard == null));

    if (realGuards.length > 0 && guard == null) {
      throw ModularError("Path guarded : $path");
    }
    return null;
  }

  static List<RouteGuard> _masterRouteGuards;

  static ModularRouter _searchInModule(
      ChildModule module, String routerName, String path) {
    path = "/$path".replaceAll('//', '/');
    final routers = module.routers;
    routers.sort((preview, actual) {
      return preview.routerName.contains('/:') ? 1 : 0;
    });
    for (var route in routers) {
      final tempRouteName =
          (routerName + route.routerName).replaceFirst('//', '/');
      if (route.child == null) {
        _masterRouteGuards = route.guards;
        var _routerName =
            ('$routerName${route.routerName}/').replaceFirst('//', '/');
        ModularRouter router;
        if (_routerName == path || _routerName == "$path/") {
          final guard = _verifyGuard(route.guards, path);
          if (guard != null) {
            return null;
          }
          router = route.module.routers[0];
          if (router.module != null) {
            var _routerName =
                (routerName + route.routerName).replaceFirst('//', '/');
            router = _searchInModule(route.module, _routerName, path);
          }
        } else {
          router = _searchInModule(route.module, _routerName, path);
        }

        if (router != null) {
          router = router.modulePath == null
              ? router.copyWith(modulePath: tempRouteName)
              : router;
          if (_routerName == path || _routerName == "$path/") {
            final guard = _verifyGuard(router.guards, path);
            if (guard != null) {
              return null;
            }
          }

          if (router.transition == TransitionType.defaultTransition) {
            router = router.copyWith(
              transition: route.transition,
              customTransition: route.customTransition,
            );
          }
          bindModule(route.module, path);
          return router;
        }
      } else {
        if (searchRoute(route, tempRouteName, path)) {
          var guards = _prepareGuardList(_masterRouteGuards, route.guards);
          _masterRouteGuards = null;
          var guard = _verifyGuard(guards, path);
          if ((tempRouteName == path || tempRouteName == "$path/") &&
              path != '/') {
            guard = _verifyGuard(guards, path);
          }
          return guard == null ? route : null;
        }
      }
    }
    return null;
  }

  static List<RouteGuard> _prepareGuardList(
      List<RouteGuard> moduleGuard, List<RouteGuard> routeGuard) {
    if (moduleGuard == null) {
      moduleGuard = [];
    }
    if (routeGuard == null) {
      routeGuard = [];
    }

    return List<RouteGuard>.from([...moduleGuard, ...routeGuard]);
  }

  @visibleForTesting
  static ModularRouter selectRoute(String path, [ChildModule module]) {
    if (path.isEmpty) {
      throw Exception("Router can not be empty");
    }
    final route = _searchInModule(module ?? _initialModule, "", path);
    return route;
  }

  static void oldProccess(Old $old) {
    if ($old?.args != null) _args = $old?.args?.copy();
    if ($old?.link != null) _routeLink = $old?.link?.copy();
  }

  static Route<T> generateRoute<T>(RouteSettings settings,
      [ChildModule module, void Function(String) onChangeRoute]) {
    final isRouterOutlet = module != null;
    final path = settings.name;
    var router = selectRoute(path, module);
    if (router == null) {
      return null;
    }
    if (!isRouterOutlet) {
      _old = Old(
        args: args,
        link: link,
      );
      updateCurrentModule("app");
    }

    _args = ModularArguments(router.params, settings.arguments);

    _routeLink = RouteLink(path: path, modulePath: router.modulePath);

    if (settings.name == Modular.initialRoute) {
      router = router.copyWith(transition: TransitionType.noTransition);
    }

    if (onChangeRoute != null) {
      onChangeRoute(path);
    }

    return router.getPageRoute(
        settings: settings,
        injectMap: _injectMap,
        isRouterOutlet: isRouterOutlet);
  }

  static void addCoreInit(ChildModule module) {
    var tagText = module.runtimeType.toString();
    addCoreInitFromTag(module, tagText);
  }

  static void addCoreInitFromTag(ChildModule module, String tagText) {
    module.instance();
    _injectMap[tagText] = module;
  }
}

class ModularArguments {
  final Map<String, dynamic> params;
  final dynamic data;

  ModularArguments(this.params, this.data);

  ModularArguments copy() {
    return ModularArguments(params, data);
  }
}
