import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/interfaces/route_guard.dart';
import 'package:flutter_modular/src/transitions/transitions.dart';

typedef RouteBuilder<T> = MaterialPageRoute<T> Function(
    WidgetBuilder, RouteSettings);

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

class Router<T> {
  final String routerName;
  final Widget Function(BuildContext context, ModularArguments args) child;
  final ChildModule module;
  Map<String, String> params;
  final List<RouteGuard> guards;
  final TransitionType transition;
  final CustomTransition customTransition;
  final RouteBuilder<T> routeGenerator;
  final String modulePath;

  Router(
    this.routerName, {
    this.module,
    this.child,
    this.guards,
    this.params,
    this.transition = TransitionType.defaultTransition,
    this.routeGenerator,
    this.customTransition,
    this.modulePath,
  }) {
    assert(routerName != null);

    if (transition == null) throw ArgumentError('transition must not be null');
    if (transition == TransitionType.custom && customTransition == null)
      throw ArgumentError(
          '[customTransition] required for transition type [TransitionType.custom]');
    if (module == null && child == null)
      throw ArgumentError('[module] or [child] must be provided');
    if (module != null && child != null)
      throw ArgumentError('You should provide only [module] or [child]');
  }
  Map<
      TransitionType,
      PageRouteBuilder<T> Function(
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

  Router<T> copyWith(
      {Widget Function(BuildContext context, ModularArguments args) child,
      String routerName,
      ChildModule module,
      Map<String, String> params,
      List<RouteGuard> guards,
      TransitionType transition,
      RouteBuilder routeGenerator,
      String modulePath,
      CustomTransition customTransition}) {
    return Router<T>(
      routerName ?? this.routerName,
      child: child ?? this.child,
      module: module ?? this.module,
      params: params ?? this.params,
      modulePath: modulePath ?? this.modulePath,
      guards: guards ?? this.guards,
      routeGenerator: routeGenerator ?? this.routeGenerator,
      transition: transition ?? this.transition,
      customTransition: customTransition ?? this.customTransition,
    );
  }

  static List<Router> group({
    @required List<Router> routes,
    List<RouteGuard> guards,
    TransitionType transition,
    CustomTransition customTransition,
  }) {
    return routes.map((r) {
      return r.copyWith(
        guards: guards,
        transition: transition ?? r.transition,
        customTransition: customTransition ?? r.customTransition,
      );
    }).toList();
  }

  Widget _disposableGenerate(BuildContext context,
      {Map<String, ChildModule> injectMap,
      bool isRouterOutlet,
      String path,
      ModularArguments args}) {
    var actual = ModalRoute.of(context);
    final _old = Modular.old;

    Widget page = _DisposableWidget(
      child: this.child(context, args),
      dispose: () {
        final List<String> trash = [];
        if (!isRouterOutlet) {
          Modular.oldProccess(_old);
        }
        if (actual.isCurrent) {
          return;
        }
        injectMap.forEach((key, module) {
          module.paths.remove(path);
          if (module.paths.length == 0) {
            module.cleanInjects();
            trash.add(key);
            _debugPrintModular("-- ${module.runtimeType.toString()} DISPOSED");
          }
        });

        trash.forEach((key) {
          injectMap.remove(key);
        });
      },
    );
    return page;
  }

  Route<T> getPageRoute(
      {Map<String, ChildModule> injectMap,
      RouteSettings settings,
      bool isRouterOutlet}) {
    final arguments = Modular.args.copy();

    if (this.transition == TransitionType.custom &&
        this.customTransition != null) {
      return PageRouteBuilder(
        pageBuilder: (context, _, __) {
          return _disposableGenerate(context,
              args: arguments,
              injectMap: injectMap,
              path: settings.name,
              isRouterOutlet: isRouterOutlet);
        },
        settings: settings,
        transitionsBuilder: this.customTransition.transitionBuilder,
        transitionDuration: this.customTransition.transitionDuration,
      );
    } else if (this.transition == TransitionType.defaultTransition) {
      var widgetBuilder = (context) => _disposableGenerate(context,
          args: arguments,
          injectMap: injectMap,
          path: settings.name,
          isRouterOutlet: isRouterOutlet);
      if (routeGenerator != null) {
        return routeGenerator(widgetBuilder, settings);
      }
      return Modular.isCupertino
          ? CupertinoPageRoute<T>(
              settings: settings,
              builder: widgetBuilder,
            )
          : MaterialPageRoute<T>(
              settings: settings,
              builder: widgetBuilder,
            );
    } else {
      var selectTransition = _transitions[this.transition];
      return selectTransition((context, args) {
        return _disposableGenerate(context,
            args: args,
            injectMap: injectMap,
            path: settings.name,
            isRouterOutlet: isRouterOutlet);
      }, arguments, settings);
    }
  }
}

enum TransitionType {
  defaultTransition,
  fadeIn,
  noTransition,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
  custom,
}

class CustomTransition {
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)
      transitionBuilder;
  final Duration transitionDuration;

  CustomTransition(
      {@required this.transitionBuilder,
      this.transitionDuration = const Duration(milliseconds: 300)});
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
