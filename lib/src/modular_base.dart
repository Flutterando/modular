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
    T value = _injectMap[tag].get<T>() ?? _injectMap["global=="].get<T>();
    if (value == null) {
      throw Exception('${T.toString()} not found in module $tag');
    }

    return _injectMap[tag].get<T>();
  }

  static T removeInjectableObject<T>(String tag) {
    return _injectMap[tag].remove<T>();
  }

  @visibleForTesting
  static Router selectRoute(String path) {
    if (path.isEmpty) {
      throw Exception("Router can not be empty");
    }

    List<String> paths = path.split('.');

    if (paths.first.isEmpty) {
      paths.removeAt(0);
    }
    Router route;
    var routeList = _initialModule.routers;
    List<ChildModule> requestBind = [];
    paths.forEach((item) {
      item = "/$item";

        if(route == null)
        route = routeList.firstWhere((router) => router.routerName == item,
            orElse: () => null);
        else {
          item = route.routerName + item;
          route = routeList.firstWhere((router) => router.routerName == item,
            orElse: () => null);
        }
      

      if (route?.module != null) {
        final m = route.module;
        requestBind.add(m);
        routeList = m.routers;
        route = route.module.routers.firstWhere(
            (router) => router.routerName == item,
            orElse: () => null);
      }
    });

    requestBind.forEach((module){
      bindModule(module, path);
    });

    return route;
  }

  static MaterialPageRoute _defaultPageRouter(
      Widget Function(BuildContext) builder) {
    return MaterialPageRoute(builder: builder);
  }

  static Route<dynamic> generateRoute(RouteSettings settings,
      {Function(Widget Function(BuildContext) builder) pageRoute =
          _defaultPageRouter}) {
    String path = settings.name.replaceAll('/', '.');
    Router router = selectRoute(path);
    if (router == null) {
      return null;
    }

    if(settings.isInitialRoute) {
      return _NoAnimationMaterialPageRoute(builder: (context) => router.child(context, settings.arguments));
    }

    return pageRoute(
      (context) {
        Widget page = _DisposableWidget(
          child: router.child(context, settings.arguments),
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
