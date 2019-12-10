import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/routers/router.dart';

import 'interfaces/child_module.dart';

class Modular {
  static Map<String, ChildModule> _injectMap = {};
  static ChildModule _initialModule;

  static init(ChildModule module) {
    _initialModule = module;
    bindModule(module, "global==");
  }

  @visibleForTesting
  static void bindModule(ChildModule module, String path) {
    assert(module != null);
    String name = module.runtimeType.toString();
    if (!_injectMap.containsKey(name)) {
      module.paths.add(path);
      _injectMap[name] = module;
      print("-- ${module.runtimeType.toString()} INITIALIZED");
    }
  }

  @visibleForTesting
  static void removeModule(ChildModule module) {
    String name = module.runtimeType.toString();
    if (_injectMap.containsKey(name)) {
      _injectMap[name].cleanInjects();
      _injectMap.remove(name);
    }
  }

  static T getInjectableObject<T>(String tag, {Map<String, dynamic> params}) {
    T value =
        _injectMap[tag].get<T>(params) ?? _injectMap["global=="].get<T>(params);
    if (value == null) {
      throw Exception('${T.toString()} not found in module $tag');
    }

    return value;
  }

  static T removeInjectableObject<T>(String tag) {
    return _injectMap[tag].remove<T>();
  }

  @visibleForTesting
  static String prepareToRegex(String url) {
    List<String> newUrl = [];
    for (var part in url.split('/')) {
      if (part.contains(":")) {
        newUrl.add("${part.replaceFirst(':', '(?<')}>.*)");
      } else {
        newUrl.add(part);
      }
    }

    return newUrl.join("/");
  }
  @visibleForTesting
  static dynamic convertType(String value){
    if(int.tryParse(value) != null ) {
      return int.parse(value);
    } else if(double.tryParse(value) != null) {
      return double.parse(value);
    } else if(value.toLowerCase() == 'true') {
      return true;
    } else if(value.toLowerCase() == 'false') {
      return false;
    }  else {
      return value;
    }
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
        Map<String, dynamic> params = {};
        int count = 1;
        for (var key in r?.groupNames) {
          routeNamed = routeNamed.replaceFirst(':$key', r?.group(count));
          params[key] = Modular.convertType("${r?.group(count)}");
          count++;
        }
        if (routeNamed != path) {
          router.params = null;
          return false;
        }
        router.params = params;
        return true;
      } else {
        router.params = null;
        return false;
      }
    }
    return routeNamed == path;
  }

  static Router _searchInModule(
      ChildModule module, String routerName, String path) {
    
    path = "/$path".replaceAll('//', '/');

    for (var route in module.routers) {
      String tempRouteName = (routerName + route.routerName).replaceFirst('//', '/');
      if (route.child == null) {
        routerName = (routerName + route.routerName).replaceFirst('//', '/');
        Router router;
        if(routerName == path){
          router = route.module.routers[0];
          if(router.module != null) {
            routerName = (routerName + route.routerName).replaceFirst('//', '/');
            router = _searchInModule(route.module, routerName, path);
          }
        } else {
          router = _searchInModule(route.module, routerName, path);
        }
        
        if (router != null) {
          bindModule(route.module, path);
          return router;
        }
      } else {
        if (searchRoute(route, tempRouteName, path)) {
          return route;
        }
      }
    }
    return null;
  }

  @visibleForTesting
  static Router selectRoute(String path) {
    if (path.isEmpty) {
      throw Exception("Router can not be empty");
    }
    Router route = _searchInModule(_initialModule, "", path);
    return route;
  }

  // @visibleForTesting
  // static Router selectRoute(String path) {
  //   if (path.isEmpty) {
  //     throw Exception("Router can not be empty");
  //   }

  //   List<String> paths = path.split('/');

  //   if (paths.first.isEmpty) {
  //     paths.removeAt(0);
  //   }
  //   Router route;
  //   var module = _initialModule;
  //   List<ChildModule> requestBind = [];
  //   for(var i = 0; i < paths.length; i++){
  //     String item = paths[i];
  //     item = "/$item";

  //     if (route == null)
  //       route = module.routers.firstWhere((router) => searchRoute(router, item),
  //           orElse: () => _initialModule == module ? module.routers[0] : null);
  //     else {
  //       item = route.routerName + item;
  //       route = module.routers.firstWhere((router) => searchRoute(router, item),
  //           orElse: () => null);
  //     }

  //     if (route?.module != null) {
  //       final m = route.module;
  //       requestBind.add(m);
  //       module = m;
  //       route = route.module.routers.firstWhere(
  //           (router) => searchRoute(router, item),
  //           orElse: () => i == (paths.length - 1) ? route.module.routers[0] : null);
  //     }
  //   }

  //   requestBind.forEach((module) {
  //     bindModule(module, path);
  //   });

  //   return route;
  // }

  static MaterialPageRoute _defaultPageRouter(
      Widget Function(BuildContext) builder) {
    return MaterialPageRoute(builder: builder);
  }

  static Route<dynamic> generateRoute(RouteSettings settings,
      {Function(Widget Function(BuildContext) builder) pageRoute =
          _defaultPageRouter}) {
    String path = settings.name;
    Router router = selectRoute(path);
    if (router == null) {
      return null;
    }

    ModularArguments args = ModularArguments(router.params, settings.arguments);

    if (settings.isInitialRoute) {
      return _NoAnimationMaterialPageRoute(
          builder: (context) => router.child(context, args));
    }

    return pageRoute(
      (context) {
        Widget page = _DisposableWidget(
          child: router.child(context, args),
          dispose: () {
            final List<String> trash = [];
            _injectMap.forEach((key, module) {
              module.paths.removeWhere((v) => v == path);
              if (module.paths.length == 0) {
                module.cleanInjects();
                trash.add(key);
                print("-- ${module.runtimeType.toString()} DISPOSED");
              }
            });

            trash.forEach((key) {
              _injectMap.remove(key);
            });
          },
        );
        return page;
      },
    );
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

  const _DisposableWidget({Key key, this.dispose, this.child})
      : super(key: key);

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
