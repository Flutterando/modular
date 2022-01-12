import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:flutter_modular/src/presenter/models/modular_args.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:modular_core/modular_core.dart';

class ModularPage<T> extends Page<T> {
  final ParallelRoute route;
  final bool isEmpty;
  final ModularFlags flags;
  final ModularArguments args;

  ModularPage(
      {LocalKey? key,
      required this.route,
      this.isEmpty = false,
      required this.args,
      required this.flags})
      : super(key: key, name: route.uri.toString(), arguments: args.data);

  factory ModularPage.empty() {
    return ModularPage(
        isEmpty: true,
        route: ParallelRoute.empty(),
        args: ModularArguments.empty(),
        flags: ModularFlags());
  }

  @override
  Route<T> createRoute(BuildContext context) {
    late final Widget page;
    if (route.child != null) {
      page = route.child!(context, args);
    } else {
      throw ModularPageException('Child not be null');
    }

    final transitionType = route.transition ?? TransitionType.defaultTransition;

    if (transitionType == TransitionType.custom &&
        route.customTransition != null) {
      return PageRouteBuilder<T>(
        pageBuilder: (context, _, __) => page,
        settings: this,
        maintainState: true,
        transitionsBuilder: route.customTransition!.transitionBuilder,
        transitionDuration: route.customTransition!.transitionDuration,
      );
    } else if (transitionType == TransitionType.defaultTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) => page;

      if (route.routeGenerator != null) {
        return route.routeGenerator!(widgetBuilder, this) as Route<T>;
      }

      if (flags.isCupertino) {
        return CupertinoPageRoute<T>(
          settings: this,
          maintainState: true,
          builder: widgetBuilder,
        );
      }
      return MaterialPageRoute<T>(
        settings: this,
        maintainState: true,
        builder: widgetBuilder,
      );
    } else if (transitionType == TransitionType.noTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) => page;

      if (route.routeGenerator != null) {
        return route.routeGenerator!(widgetBuilder, this) as Route<T>;
      }

      return NoTransitionMaterialPageRoute<T>(
        settings: this,
        maintainState: true,
        builder: (_) => page,
      );
    } else {
      var selectTransition = route.transitions[transitionType];
      return selectTransition!(
          (_, __) => page,
          route.duration ?? const Duration(milliseconds: 300),
          this) as Route<T>;
    }
  }
}

// class ModularRouteSettings extends Route {
//   final ModularPage page;

//   ModularRouteSettings(this.page) : super(settings: page);
// }

class NoTransitionMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoTransitionMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
