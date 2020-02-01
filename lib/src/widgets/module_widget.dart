import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract class ModuleWidget extends StatelessWidget {
  List<Bind> get binds;

  Widget get view;

  @override
  Widget build(BuildContext context) {
    return _ModularProvider(
      tagText: this.runtimeType.toString(),
      module: _FakeModule(
        path: this.runtimeType.toString(),
        bindsInject: binds,
      ),
      child: view,
    );
  }
}

class _FakeModule extends ChildModule {
  final List<Bind> bindsInject;

  _FakeModule({String path, this.bindsInject}) {
    this.paths.add(this.runtimeType.toString());
  }

  @override
  List<Bind> get binds => bindsInject;

  @override
  List<Router> get routers => null;
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
    Modular.addCoreInitFromTag(widget.module, widget.tagText);
    print("-- ${widget.tagText} INITIALIZED");
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    Modular.removeModule(null, widget.tagText);
    print("-- ${widget.tagText} DISPOSED");
  }
}
