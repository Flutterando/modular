import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract class ModuleWidget extends StatelessWidget with ChildModule {
  ModuleWidget() {
    this.paths.add(this.runtimeType.toString());
  }
  @override
  List<Router> get routers => null;

  Widget get view;

  @override
  Widget build(BuildContext context) {
    return _ModularProvider(
      tagText: this.runtimeType.toString(),
      module: this,
      child: view,
    );
  }
}

class _ModularProvider extends StatefulWidget {
  final ChildModule module;
  final Widget child;
  final String tagText;

  const _ModularProvider({Key key, this.module, this.tagText, this.child})
      : super(key: key);

  @override
  __ModularProviderState createState() => __ModularProviderState();
}

class __ModularProviderState extends State<_ModularProvider> {
  @override
  void initState() {
    super.initState();
    Modular.addCoreInit(widget.module);
    print("-- ${widget.module.runtimeType.toString()} INITIALIZED");
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    Modular.removeModule(widget.module);
    print("-- ${widget.module.runtimeType.toString()} DISPOSED");
  }
}
