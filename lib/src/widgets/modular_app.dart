import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/interfaces/main_module.dart';

class ModularApp extends StatefulWidget {
  final MainModule module;

  const ModularApp({Key key, this.module}) : super(key: key);

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
    super.dispose();
    widget.module.cleanInjects();
    print("-- ${widget.module.runtimeType.toString()} DISPOSED");
  }

  @override
  Widget build(BuildContext context) {
    return widget.module.bootstrap;
  }
}
