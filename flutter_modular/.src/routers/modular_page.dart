import 'dart:async';

import 'package:flutter/material.dart';

import '../../flutter_modular.dart';

final Map<int, Completer> _allCompleters = {};

class ModularPage<T> extends Page<T> {
  final ModularRoute router;

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
    return router.getPageRoute<T>(this);
  }

  // @override
  // bool operator ==(Object o) {
  //   if (identical(this, o)) return true;

  //   return o is ModularPage<T> && o.router == router;
  // }

  // @override
  // int get hashCode => router.hashCode;
}

class ModularRoute extends Route {
  final ModularPage page;

  ModularRoute(this.page) : super(settings: page);
}
