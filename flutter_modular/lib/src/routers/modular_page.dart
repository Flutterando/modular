import 'package:flutter/material.dart';
import '../../flutter_modular.dart';

class ModularPage extends Page {
  final ModularRouter router;

  ModularPage({Key key, this.router})
      : super(key: key, name: router.path, arguments: router.args.data);

  @override
  Route createRoute(BuildContext context) {
    return router.getPageRoute(this);
  }
}
