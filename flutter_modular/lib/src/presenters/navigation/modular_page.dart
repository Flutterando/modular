import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/src/core/errors/errors.dart';
import '../../core/models/modular_router.dart';

final Map<int, Completer> _allCompleters = {};

class ModularPage<T> extends Page<T> {
  final ModularRouter router;

  ModularPage({LocalKey? key, required this.router})
      : super(key: key, name: router.path, arguments: router.args?.data);

  Future<T> waitPop() {
    if (_allCompleters.containsKey(hashCode)) {
      return (_allCompleters[hashCode] as Completer<T>).future;
    } else {
      _allCompleters[hashCode] = Completer<T>();
      return (_allCompleters[hashCode] as Completer<T>).future;
    }
  }

  void completePop(T result) {
    if (_allCompleters.containsKey(hashCode) &&
        !(_allCompleters[hashCode] as Completer<T>).isCompleted) {
      (_allCompleters[hashCode] as Completer<T>).complete(result);
      _allCompleters.remove(hashCode);
    }
  }

  @override
  Route<T> createRoute(BuildContext context) {
    if (router.transition == TransitionType.custom &&
        router.customTransition != null) {
      return PageRouteBuilder<T>(
        pageBuilder: (context, _, __) {
          if (router.child != null) {
            return router.child!(context, router.args);
          } else {
            throw ModularError('Child not be null');
          }
        },
        settings: this,
        transitionsBuilder: router.customTransition!.transitionBuilder,
        transitionDuration: router.customTransition!.transitionDuration,
      );
    } else if (router.transition == TransitionType.defaultTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) {
        //return disposablePage;
        return router.child!(context, router.args);
      }

      if (router.routeGenerator != null) {
        return router.routeGenerator!(widgetBuilder, this) as Route<T>;
      }
      return MaterialPageRoute<T>(
        settings: this,
        builder: widgetBuilder,
      );
    } else {
      var selectTransition = router.transitions[router.transition];
      if (selectTransition != null) {
        return selectTransition(
            router.child!, router.args, router.duration, this) as Route<T>;
      } else {
        throw ModularError('Page Not Found');
      }
    }
  }
}

class ModularRoute extends Route {
  final ModularPage page;

  ModularRoute(this.page) : super(settings: page);
}
