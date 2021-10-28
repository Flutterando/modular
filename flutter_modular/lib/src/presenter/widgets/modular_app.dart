import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:triple/triple.dart';

import '../modular_base.dart';

/// Widget responsible for starting the Modular engine.
/// This should be, if possible, the first widget in your application.
class ModularApp extends StatefulWidget {
  /// Initial module.
  /// This module will only be destroyed when the application is finished.
  final Module module;

  /// Home application containing the MaterialApp or CupertinoApp.
  final Widget child;

  ModularApp({
    Key? key,
    required this.module,
    required this.child,

    /// Home application containing the MaterialApp or CupertinoApp.
    bool debugMode = true,

    /// Prohibits taking any bind of parent modules, forcing the imports of the same in the current module to be accessed. This is the same behavior as the system. Default is false;
    bool notAllowedParentBinds = false,
  }) : super(key: key) {
    (Modular as ModularBase).flags.experimentalNotAllowedParentBinds =
        notAllowedParentBinds;
    (Modular as ModularBase).flags.isDebug = debugMode;
  }

  @override
  ModularAppState createState() => ModularAppState();
}

class ModularAppState extends State<ModularApp> {
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
    Modular.debugPrintModular(
        '-- ${widget.module.runtimeType.toString()} DISPOSED');
    cleanGlobals();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    Modular.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
