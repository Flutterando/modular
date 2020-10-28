import 'dart:async';

import 'package:flutter/material.dart';
import '../../flutter_modular.dart';

final Map<int, Completer> _allCompleters = {};

class ModularPage<T> extends Page<T> {
  final ModularRouter router;

  const ModularPage({Key key, this.router, String path, T arguments})
      : super(key: key, name: path, arguments: arguments);

  Future<T> waitPop() {
    if (_allCompleters.containsKey(hashCode)) {
      return _allCompleters[hashCode].future;
    } else {
      _allCompleters[hashCode] = Completer<T>();
      return _allCompleters[hashCode].future;
    }
  }

  void completePop(T result) {
    if (_allCompleters.containsKey(hashCode) &&
        !_allCompleters[hashCode].isCompleted) {
      _allCompleters[hashCode].complete(result);
      _allCompleters.remove(hashCode);
    }
  }

  @override
  Route<T> createRoute(BuildContext context) {
    return router.getPageRoute(this);
  }
}

class ModularRoute extends Route {
  final ModularPage page;

  ModularRoute(this.page) : super(settings: page);
}
