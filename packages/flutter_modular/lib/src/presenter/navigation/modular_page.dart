import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../errors/errors.dart';
import '../models/modular_args.dart';
import '../models/route.dart';
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
      final transition = route.customTransition!;
      return PageRouteBuilder<T>(
        pageBuilder: transition.pageBuilder ?? (context, _, __) => page,
        opaque: transition.opaque,
        settings: this,
        maintainState: route.maintainState,
        transitionsBuilder: transition.transitionBuilder,
        transitionDuration: transition.transitionDuration,
      );
    } else if (transitionType == TransitionType.defaultTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) => page;

      if (flags.isCupertino) {
        return CupertinoPageRoute<T>(
          settings: this,
          maintainState: route.maintainState,
          builder: widgetBuilder,
        );
      }
      return MaterialPageRoute<T>(
        settings: this,
        maintainState: route.maintainState,
        builder: widgetBuilder,
      );
    } else if (transitionType == TransitionType.noTransition) {
      return NoTransitionMaterialPageRoute<T>(
        settings: this,
        maintainState: route.maintainState,
        builder: (_) => page,
      );
    } else {
      var selectTransition = route.transitions[transitionType];
      return selectTransition!(
          (_, __) => page,
          route.duration ?? const Duration(milliseconds: 300),
          this,
          route.maintainState) as Route<T>;
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
