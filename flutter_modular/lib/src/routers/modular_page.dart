import 'package:flutter/material.dart';
import '../../flutter_modular.dart';

class ModularPage extends Page {
  final ModularRouter router;

  ModularPage(this.router) : super(key: ValueKey(router.path));

  @override
  Route createRoute(BuildContext context) {
    return router.getPageRoute(this);
  }
}
