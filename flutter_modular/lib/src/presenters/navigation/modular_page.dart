import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/errors/errors.dart';
import '../../core/interfaces/modular_route.dart';
import '../modular_base.dart';

final Map<int, Completer> _allCompleters = {};

class ModularPage<T> extends Page<T> {
  final ModularRoute router;

  ModularPage({LocalKey? key, required this.router}) : super(key: key, name: router.path, arguments: router.args.data);

  Future<T?> waitPop() {
    if (_allCompleters.containsKey(hashCode)) {
      return (_allCompleters[hashCode] as Completer<T?>).future;
    } else {
      _allCompleters[hashCode] = Completer<T?>();
      return (_allCompleters[hashCode] as Completer<T?>).future;
    }
  }

  void completePop(T? result) {
    if (_allCompleters.containsKey(hashCode) && !(_allCompleters[hashCode] as Completer<T?>).isCompleted) {
      final complete = (_allCompleters[hashCode] as Completer<T?>);
      complete.complete(result);
      _allCompleters.remove(hashCode);
    }
  }

  @override
  Route<T> createRoute(BuildContext context) {
    late final Widget page;
    if (router.child != null) {
      page = router.child!(context, Modular.args!);
    } else {
      throw ModularError('Child not be null');
    }
    if (router.transition == TransitionType.custom && router.customTransition != null) {
      return PageRouteBuilder<T>(
        pageBuilder: (context, _, __) => page,
        settings: this,
        transitionsBuilder: router.customTransition!.transitionBuilder,
        transitionDuration: router.customTransition!.transitionDuration,
      );
    } else if (router.transition == TransitionType.defaultTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) => page;

      if (router.routeGenerator != null) {
        return router.routeGenerator!(widgetBuilder, this) as Route<T>;
      }
      if (Modular.flags.isCupertino) {
        return CupertinoPageRoute<T>(
          settings: this,
          builder: widgetBuilder,
        );
      }
      return MaterialPageRoute<T>(
        settings: this,
        builder: widgetBuilder,
      );
    } else if (router.transition == TransitionType.noTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) {
        //return disposablePage;
        return page;
      }

      if (router.routeGenerator != null) {
        return router.routeGenerator!(widgetBuilder, this) as Route<T>;
      }
      return NoTransitionMaterialPageRoute<T>(
        settings: this,
        builder: widgetBuilder,
      );
    } else {
      var selectTransition = router.transitions[router.transition];
      if (selectTransition != null) {
        return selectTransition((_, __) => page, router.duration, this) as Route<T>;
      } else {
        throw ModularError('Page Not Found');
      }
    }
  }
}

class ModularRouteSettings extends Route {
  final ModularPage page;

  ModularRouteSettings(this.page) : super(settings: page);
}

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
