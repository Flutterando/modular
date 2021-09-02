import 'dart:async';

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

  ModularPage({LocalKey? key, required this.route, this.isEmpty = false, required this.args, required this.flags}) : super(key: key, name: route.uri.toString(), arguments: args.data);

  factory ModularPage.empty() {
    return ModularPage(isEmpty: true, route: ParallelRoute.empty(), args: ModularArguments.empty(), flags: ModularFlags());
  }

  @override
  Route<T> createRoute(BuildContext context) {
    late final Widget page;
    if (route.child != null) {
      page = route.child!(context, args);
    } else {
      throw ModularPageException('Child not be null');
    }
    if (route.transition == TransitionType.custom && route.customTransition != null) {
      return PageRouteBuilder<T>(
        pageBuilder: (context, _, __) => page,
        settings: this,
        transitionsBuilder: route.customTransition!.transitionBuilder,
        transitionDuration: route.customTransition!.transitionDuration,
      );
    } else if (route.transition == TransitionType.defaultTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) => page;

      if (flags.isCupertino) {
        return CupertinoPageRoute<T>(
          settings: this,
          builder: widgetBuilder,
        );
      }
      return MaterialPageRoute<T>(
        settings: this,
        builder: widgetBuilder,
      );
    } else if (route.transition == TransitionType.noTransition) {
      return NoTransitionMaterialPageRoute<T>(
        settings: this,
        builder: (_) => page,
      );
    } else {
      var selectTransition = route.transitions[route.transition];
      return selectTransition!((_, __) => page, route.duration, this) as Route<T>;
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
  }) : super(builder: builder, maintainState: maintainState, settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
