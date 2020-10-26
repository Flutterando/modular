import 'package:flutter/material.dart';
import '../../flutter_modular.dart';

class ModularPage extends Page {
  final ModularRouter router;

  const ModularPage({Key key, this.router}) : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return router.getPageRoute(this);
  }
}
