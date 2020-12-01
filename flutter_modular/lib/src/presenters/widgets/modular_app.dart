import 'package:flutter/widgets.dart';
import '../../core/modules/main_module.dart';

import '../modular_base.dart';

class ModularApp extends StatefulWidget {
  final MainModule module;

  ModularApp({
    Key? key,
    required this.module,
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
    return widget.module.bootstrap;
  }
}
