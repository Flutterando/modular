import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../flutter_modular.dart';
import '../interfaces/child_module.dart';
import '../interfaces/route_guard.dart';
import '../transitions/transitions.dart';
import '../utils/old.dart';

typedef RouteBuilder<T> = MaterialPageRoute<T> Function(
    WidgetBuilder, RouteSettings);

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

class ModularRouter<T> {
  ///
  /// Paramenter name: [routerName]
  ///
  /// Name for your route
  ///
  /// Type: String
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final String routerName;

  ///
  /// Paramenter name: [child]
  ///
  /// The widget will be displayed
  ///
  /// Type: Widget
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///

  final Widget Function(BuildContext context, ModularArguments args) child;

  ///
  /// Paramenter name: [module]
  ///
  /// The module will be loaded
  ///
  /// Type: ChildModule
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final ChildModule module;

  ///
  /// Paramenter name: [params]
  ///
  /// The parameters that can be transferred to another screen
  ///
  /// Type: Map<String, String>
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  Map<String, String> params;

  ///
  /// Paramenter name: [guards]
  ///
  /// Route guards are middleware-like objects
  ///
  /// that allow you to control the access of a given route from other route.
  ///
  /// You can implement a route guard by making a class that implements RouteGuard.
  ///
  /// Type: List<RouteGuard>
  ///
  /// Example:
  /// ```dart
  ///class MyGuard implements RouteGuard {
  ///  @override
  ///  bool canActivate(String url) {
  ///    if (url != '/admin'){
  ///      // Return `true` to allow access
  ///      return true;
  ///    } else {
  ///      // Return `false` to disallow access
  ///      return false
  ///    }
  ///  }
  ///}
  ///To use your RouteGuard in a route, pass it to the guards parameter:
  ///
  ///@override
  ///List<Router> get routers => [
  ///  Router('/', module: HomeModule()),
  ///  Router(
  ///    '/admin',
  ///    module: AdminModule(),
  ///    guards: [MyGuard()],
  ///  ),
  ///];
  /// ```
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///

  final List<RouteGuard> guards;

  ///
  /// Paramenter name: [transition]
  ///
  /// Used to animate the transition from one screen to another
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final TransitionType transition;

  ///
  /// Paramenter name: [customTransiton]
  ///
  /// PS: For [customTransition] to work,
  ///
  /// you must set the [transition] parameter for
  /// ```dart
  /// transition.custom,
  /// ```
  ///
  /// Example: Using just First Animation
  /// ```dart
  /// customTransition: CustomTransition(
  ///   transitionBuilder: (context, animation, secondaryAnimation, child) {
  ///     return SlideTransition(
  ///         transformHitTests: false,
  ///         position: Tween<Offset>(
  ///           begin: const Offset(0.0, 1.0),
  ///           end: Offset.zero,
  ///         ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  ///         child: child);
  ///   },
  /// ),
  /// ```

  /// Example: Using just secondaryAnimation
  /// ```dart
  /// customTransition: CustomTransition(
  /// transitionBuilder: (context, animation, secondaryAnimation, child) {
  ///   return SlideTransition(
  ///     transformHitTests: false,
  ///     position: Tween<Offset>(
  ///       begin: const Offset(0.0, 1.0),
  ///       end: Offset.zero,
  ///     ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  ///     child: SlideTransition(
  ///       transformHitTests: false,
  ///       position: Tween<Offset>(
  ///         begin: Offset.zero,
  ///         end: const Offset(0.0, -1.0),
  ///       ).chain(CurveTween(curve: Curves.ease)).animate(secondaryAnimation),
  ///       child: child,
  ///     ),
  ///   );
  ///   },
  /// ),
  /// ```
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final CustomTransition customTransition;

  ///
  /// Paramenter name: [transition]
  ///
  /// Used to animate the transition from one screen to another
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final RouteBuilder<T> routeGenerator;
  final String modulePath;

  ModularRouter(
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
    if (transition == TransitionType.custom && customTransition == null) {
      throw ArgumentError(
          '[customTransition] required for transition type [TransitionType.custom]');
    }
    if (module == null && child == null) {
      throw ArgumentError('[module] or [child] must be provided');
    }
    if (module != null && child != null) {
      throw ArgumentError('You should provide only [module] or [child]');
    }
  }
  final Map<
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

  ModularRouter<T> copyWith(
      {Widget Function(BuildContext context, ModularArguments args) child,
      String routerName,
      ChildModule module,
      Map<String, String> params,
      List<RouteGuard> guards,
      TransitionType transition,
      RouteBuilder routeGenerator,
      String modulePath,
      CustomTransition customTransition}) {
    return ModularRouter<T>(
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

  static List<ModularRouter> group({
    @required List<ModularRouter> routes,
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

  Widget _disposableGenerate({
    Map<String, ChildModule> injectMap,
    bool isRouterOutlet,
    String path,
  }) {
    Widget page = _DisposableWidget(
      child: child,
      dispose: (old, actual) {
        final trash = <String>[];
        if (!isRouterOutlet) {
          Modular.oldProccess(old);
          Modular.updateCurrentModuleApp();
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

        for (final key in trash) {
          injectMap.remove(key);
        }
      },
    );
    return page;
  }

  Route<T> getPageRoute(
      {Map<String, ChildModule> injectMap,
      RouteSettings settings,
      bool isRouterOutlet}) {
    final disposablePage = _disposableGenerate(
        injectMap: injectMap,
        path: settings.name,
        isRouterOutlet: isRouterOutlet);

    if (transition == TransitionType.custom && customTransition != null) {
      return PageRouteBuilder(
        pageBuilder: (context, _, __) {
          return disposablePage;
        },
        settings: settings,
        transitionsBuilder: customTransition.transitionBuilder,
        transitionDuration: customTransition.transitionDuration,
      );
    } else if (transition == TransitionType.defaultTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) {
        return disposablePage;
      }

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
      var selectTransition = _transitions[transition];
      return selectTransition((context, args) {
        return disposablePage;
      }, Modular.args, settings);
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
  final Function(Old old, ModalRoute actual) dispose;
  final Widget Function(BuildContext context, ModularArguments args) child;

  _DisposableWidget({
    Key key,
    this.dispose,
    this.child,
  }) : super(key: key);

  @override
  __DisposableWidgetState createState() => __DisposableWidgetState();
}

class __DisposableWidgetState extends State<_DisposableWidget> {
  Old old;
  ModalRoute actual;
  ModularArguments args;

  @override
  void initState() {
    super.initState();
    old = Modular.old;
    args = Modular.args;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    actual = ModalRoute.of(context);
  }

  @override
  void dispose() {
    widget.dispose(old, actual);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child(context, args);
  }
}
