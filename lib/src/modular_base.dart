import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/routers/router.dart';

import 'interfaces/child_module.dart';
import 'interfaces/route_guard.dart';
import 'routers/router.dart';
import 'transitions/transitions.dart';

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

class Modular {
  static String get initialRoute => '/';
  static bool debugMode = true;

  static Map<String, ChildModule> _injectMap = {};
  static ChildModule _initialModule;
  static GlobalKey<NavigatorState> _navigatorKey;
  static ModularArguments _args;
  static ModularArguments get args => _args?.copy();

  static GlobalKey<NavigatorState> get navigatorKey {
    if (_navigatorKey == null) {
      _navigatorKey = GlobalKey<NavigatorState>();
    }

    return _navigatorKey;
  }

  static init(ChildModule module) {
    _initialModule = module;
    if (Modular.debugMode) {
      _printRouters();
    }
    bindModule(module, "global==");
  }

  static _printRouters() {
    List<Type> typesCheckds = [];
    List<String> paths = [];
    _printRoutersModule(_initialModule, '/', paths, typesCheckds);
    paths.sort((preview, actual) => preview
        .split(' => ')[0]
        .length
        .compareTo(actual.split(' => ')[0].length));
    int sizedPath = paths[paths.length - 1].split(' => ')[0].length;
    paths = paths.map((p) {
      List<String> split = p.split(' => ');
      int sizeLocalPath = split[0].length;
      if (sizedPath >= sizeLocalPath) {
        String spaces =
            List.generate(sizedPath - sizeLocalPath, (index) => ' ').join('');
        String path = split[0];
        if (path != '/' && path[path.length - 1] == '/') {
          path = path.substring(0, path.length - 1);
        }
        return "$path$spaces => ${split[1]}";
      }
      return p;
    }).toList();

    debugPrint('\n*** Modular Routers ***\n');
    paths.forEach(print);
    debugPrint("\n*****\n");
  }

  static _printRoutersModule(ChildModule module, String initialPath,
      List<String> paths, List<Type> typesCheckds) {
    typesCheckds.add(module.runtimeType);
    for (var router in module.routers.where((router) => router.child != null)) {
      String page = router.child.runtimeType
          .toString()
          .replaceFirst('(BuildContext, ModularArguments) => ', '');
      String path = "$initialPath${router.routerName}".replaceFirst('//', '/');
      paths.add('$path => $page');
    }

    bool _condition(router) => (router.module != null &&
        !typesCheckds.contains(router.module.runtimeType));

    for (var router in module.routers.where(_condition)) {
      _printRoutersModule(
          router.module, router.routerName, paths, typesCheckds);
    }
  }

  static NavigatorState get to {
    assert(
        _navigatorKey != null, '''Add Modular.navigatorKey in your MaterialApp;

      return MaterialApp(
        navigatorKey: Modular.navigatorKey,
        ...

.
      ''');
    return _navigatorKey.currentState;
  }

  @visibleForTesting
  static void bindModule(ChildModule module, [String path]) {
    assert(module != null);
    String name = module.runtimeType.toString();
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
    }
  }

  static B get<B>(
      {Map<String, dynamic> params, String module, List<Type> typesInRequest}) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    typesInRequest ??= [];

    if (module != null) {
      return _getInjectableObject<B>(module,
          params: params, typesInRequest: typesInRequest);
    } else {
      for (var key in _injectMap.keys) {
        B value = _getInjectableObject<B>(key,
            params: params, disableError: true, typesInRequest: typesInRequest);
        if (value != null) {
          return value;
        }
      }
      throw ModularError('${B.toString()} not found');
    }
  }

  static B _getInjectableObject<B>(String tag,
      {Map<String, dynamic> params,
      bool disableError = false,
      List<Type> typesInRequest}) {
    B value;
    if (_injectMap.containsKey(tag))
      value =
          _injectMap[tag].getBind<B>(params, typesInRequest: typesInRequest);
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
    List<String> newUrl = [];
    for (var part in url.split('/')) {
      var url =
          part.contains(":") ? "${part.replaceFirst(':', '(?<')}>.*)" : part;
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
  static bool searchRoute(Router router, String routeNamed, String path) {
    if (routeNamed.split('/').length != path.split('/').length) {
      return false;
    }

    if (routeNamed.contains('/:')) {
      RegExp regExp = RegExp(
        "^${prepareToRegex(routeNamed)}\$",
        caseSensitive: true,
      );
      var r = regExp.firstMatch(path);

      if (r?.groupNames != null) {
        Map<String, String> params = {};
        int count = 1;
        for (var key in r?.groupNames) {
          routeNamed = routeNamed.replaceFirst(':$key', r?.group(count));
          params[key] = r?.group(count);
          count++;
        }

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
    try {
      guard = guards.length == 0
          ? null
          : guards.firstWhere((guard) => !guard.canActivate(path),
              orElse: null);
    } catch (e) {}

    return guard;
  }

  static List<RouteGuard> _masterRouteGuards;

  static Router _searchInModule(
      ChildModule module, String routerName, String path) {
    path = "/$path".replaceAll('//', '/');
    final routers = module.routers;
    routers.sort((preview, actual) {
      bool isContain =
          preview.routerName.contains('/:') == actual.routerName.contains('/:');
      return isContain ? -1 : 1;
    });
    for (var route in routers) {
      String tempRouteName =
          (routerName + route.routerName).replaceFirst('//', '/');
      if (route.child == null) {
        _masterRouteGuards = route.guards;
        var _routerName =
            (routerName + route.routerName + '/').replaceFirst('//', '/');
        Router router;
        if (_routerName == path || _routerName == "$path/") {
          RouteGuard guard = _verifyGuard(route.guards, path);
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
          //router = _searchInModule(route.module, _routerName, path.substring(path.indexOf("/",1)));
          router = _searchInModule(route.module, _routerName, path);
        }

        if (router != null) {
          if (_routerName == path || _routerName == "$path/") {
            RouteGuard guard = _verifyGuard(router.guards, path);
            if (guard != null) {
              return null;
            }
          }

          if (router.transition == TransitionType.defaultTransition) {
            router = router.copyWith(
              transition: route.transition,
            );
          }
          bindModule(route.module, path);
          return router;
        }
      } else {
        if (searchRoute(route, tempRouteName, path)) {
          var guards = _prepareGuardList(_masterRouteGuards, route.guards);
          _masterRouteGuards = null;
          RouteGuard guard;
          try {
            guard = guards.length == 0
                ? null
                : guards.firstWhere((guard) => !guard.canActivate(path),
                    orElse: null);
          } catch (e) {}
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
  static Router selectRoute(String path) {
    if (path.isEmpty) {
      throw Exception("Router can not be empty");
    }
    Router route = _searchInModule(_initialModule, "", path);
    return route;
  }

  static MaterialPageRoute _defaultPageRouter(
      Widget Function(BuildContext) builder, RouteSettings settings) {
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  static String actualRoute = '/';
  static RouteSettings globaSetting;

  static Route<T> generateRoute<T>(RouteSettings settings) {
    String path = settings.name;
    Router router = selectRoute(path);
    if (router == null) {
      return null;
    }
    actualRoute = path;
    _args = ModularArguments(router.params, settings.arguments);

    if (settings.name == initialRoute) {
      router = router.copyWith(transition: TransitionType.noTransition);
    }

    return router.getPageRoute(settings: settings, injectMap: _injectMap);
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

class _NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  _NoAnimationMaterialPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
