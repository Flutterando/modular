import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/interfaces/main_module.dart';

class ModularApp extends StatefulWidget {
  final MainModule module;
  final bool isCupertino;

  ModularApp({
    Key key,
    this.module,
    this.isCupertino = false,
  }) : super(key: key) {
    Modular.isCupertino = isCupertino;
  }

  @override
  _ModularAppState createState() => _ModularAppState();
}

class _ModularAppState extends State<ModularApp> {
  @override
  void initState() {
    super.initState();
    Modular.init(widget.module);
  }

  @override
  void dispose() {
    widget.module.cleanInjects();
    if (Modular.debugMode) {
      debugPrint("-- ${widget.module.runtimeType.toString()} DISPOSED");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.module.bootstrap;
  }
}
