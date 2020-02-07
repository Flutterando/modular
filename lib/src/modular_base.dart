import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/routers/router.dart';

import 'interfaces/child_module.dart';
import 'interfaces/route_guard.dart';
import 'transitions/transitions.dart';

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    print(text);
  }
}

class Modular {
  static String get initialRoute => '/';
  static bool debugMode = true;

  static Map<String, ChildModule> _injectMap = {};
  static ChildModule _initialModule;
  static GlobalKey<NavigatorState> _navigatorKey;

  static GlobalKey<NavigatorState> get navigatorKey {
    if (_navigatorKey == null) {
      _navigatorKey = GlobalKey<NavigatorState>();
    }

    return _navigatorKey;
  }

  static init(ChildModule module) {
    _initialModule = module;
    bindModule(module, "global==");
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

  static B get<B>({Map<String, dynamic> params, String module}) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    if (module != null) {
      return _getInjectableObject<B>(module, params: params);
    } else {
      for (var key in _injectMap.keys) {
        B value =
            _getInjectableObject<B>(key, params: params, disableError: true);
        if (value != null) {
          return value;
        }
      }
      throw ModularError('${B.toString()} not found');
    }
  }

  static B _getInjectableObject<B>(
    String tag, {
    Map<String, dynamic> params,
    bool disableError = false,
  }) {
    B value;
    if (_injectMap.containsKey(tag)) value = _injectMap[tag].getBind<B>(params);
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

    for (var route in module.routers) {
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

  static Map<
      TransitionType,
      PageRouteBuilder Function(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings,
  )> _transitions = {
    TransitionType.fadeIn: fadeInTransition,
    TransitionType.noTransition: noTransition,
    TransitionType.rightToLeft: rightToLeft,
    TransitionType.leftToRight: leftToRight,
    TransitionType.upToDown: upToDown,
    TransitionType.downToUp: downToUp,
    TransitionType.scale: scale,
    TransitionType.rotate: rotate,
    TransitionType.size: size,
    TransitionType.rightToLeftWithFade: rightToLeftWithFade,
    TransitionType.leftToRightWithFade: leftToRightWithFade,
  };

  static String actualRoute = '/';
  static RouteSettings globaSetting;

  static Route generateRoute(
    RouteSettings settings, {
    Function(Widget Function(BuildContext) builder, RouteSettings settings)
        pageRoute = _defaultPageRouter,
  }) {
    String path = settings.name;
    Router router = selectRoute(path);
    if (router == null) {
      return null;
    }
    actualRoute = path;
    ModularArguments args = ModularArguments(router.params, settings.arguments);

    if (path == settings.isInitialRoute) {
      router = router.copyWith(transition: TransitionType.noTransition);
    }

    if (router.transition == TransitionType.defaultTransition) {
      var pageRouterGenerate = pageRoute(
        (context) {
          var actual = ModalRoute.of(context);
          Widget page = _DisposableWidget(
            child: router.child(context, args),
            dispose: () {
              final List<String> trash = [];
              if (actual.isCurrent) {
                return;
              }
              _injectMap.forEach((key, module) {
                module.paths.remove(path);
                if (module.paths.length == 0) {
                  module.cleanInjects();
                  trash.add(key);
                  _debugPrintModular(
                      "-- ${module.runtimeType.toString()} DISPOSED");
                }
              });

              trash.forEach((key) {
                _injectMap.remove(key);
              });
            },
          );
          return page;
        },
        settings,
      );
      return pageRouterGenerate;
    }
    var selectTransition = _transitions[router.transition];
    return selectTransition((context, args) {
      var actual = ModalRoute.of(context);
      return _DisposableWidget(
        child: router.child(context, args),
        dispose: () {
          final List<String> trash = [];
          if (actual.isCurrent) {
            return;
          }
          _injectMap.forEach((key, module) {
            module.paths.remove(path);
            if (module.paths.length == 0) {
              module.cleanInjects();
              trash.add(key);
              _debugPrintModular(
                  "-- ${module.runtimeType.toString()} DISPOSED");
            }
          });

          trash.forEach((key) {
            _injectMap.remove(key);
          });
        },
      );
    }, args, settings);
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

class _DisposableWidget extends StatefulWidget {
  final Function dispose;
  final Widget child;

  _DisposableWidget({
    Key key,
    this.dispose,
    this.child,
  }) : super(key: key);

  @override
  __DisposableWidgetState createState() => __DisposableWidgetState();
}

class __DisposableWidgetState extends State<_DisposableWidget> {
  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
