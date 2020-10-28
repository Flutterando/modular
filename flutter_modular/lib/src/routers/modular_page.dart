import 'dart:async';

import 'package:flutter/material.dart';
import '../../flutter_modular.dart';

class ModularPage<T> extends Page<T> {
  final ModularRouter router;
  final popRoute = Completer<T>();

  ModularPage({Key key, this.router})
      : super(key: key, name: router.path, arguments: router.args.data);

  @override
  Route<T> createRoute(BuildContext context) {
    return router.getPageRoute(this);
  }
}

class ModularRoute extends Route {
  final ModularPage page;

  ModularRoute(this.page) : super(settings: page);
}
