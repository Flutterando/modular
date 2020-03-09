import 'package:flutter/material.dart';

import '../../flutter_modular.dart';

class RouterOutlet extends StatelessWidget {
  final ChildModule module;
  final String initialRoute;
  final Key navigatorKey;

  RouterOutlet(
      {Key key,
      @required this.module,
      this.navigatorKey,
      this.initialRoute = Modular.initialRoute})
      : super(key: key) {
    this.module.paths.add(this.runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ModularProvider(
      module: module,
      child: Navigator(
        key: navigatorKey,
        initialRoute: initialRoute,
        onGenerateRoute: (setting) {
          return Modular.generateRoute(setting, module);
        },
      ),
    );
  }
}
