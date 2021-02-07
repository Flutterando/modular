import 'package:flutter/widgets.dart';
import '../../core/interfaces/module.dart';

import '../modular_base.dart';

class ModularApp extends StatefulWidget {
  final Module module;
  final Widget child;

  ModularApp({
    Key? key,
    required this.module,
    required this.child,
  }) : super(key: key);

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
    return widget.child;
  }
}
