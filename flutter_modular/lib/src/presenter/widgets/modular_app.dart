import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:triple/triple.dart';

import '../modular_base.dart';

class ModularApp extends StatefulWidget {
  final Module module;
  final Widget child;
  final bool debugMode;

  ModularApp({
    Key? key,
    required this.module,
    required this.child,
    this.debugMode = true,
    bool notAllowedParentBinds = false,
  }) : super(key: key) {
    (Modular as ModularBase).flags.experimentalNotAllowedParentBinds = notAllowedParentBinds;
    (Modular as ModularBase).flags.isDebug = debugMode;
  }

  @override
  _ModularAppState createState() => _ModularAppState();
}

class _ModularAppState extends State<ModularApp> {
  @override
  void initState() {
    super.initState();
    Modular.init(widget.module);
    setTripleResolver(tripleResolverCallback);
  }

  @visibleForTesting
  T tripleResolverCallback<T extends Object>() {
    return Modular.get<T>();
  }

  @override
  void dispose() {
    Modular.destroy();
    Modular.debugPrintModular('-- ${widget.module.runtimeType.toString()} DISPOSED');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
