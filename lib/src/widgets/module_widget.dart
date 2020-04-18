import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

abstract class ModuleWidget extends StatelessWidget implements ChildModule {
  @override
  List<Bind> get binds;

  Widget get view;

  final _FakeModule _fakeModule = _FakeModule();

  ModuleWidget() {
    _fakeModule.changeBinds(binds);
  }

  @override
  changeBinds(List<Bind> b) {
    _fakeModule.changeBinds(b);
  }

  @override
  cleanInjects() {
    _fakeModule.cleanInjects();
  }

  @override
  getBind<T>(Map<String, dynamic> params, {List<Type> typesInRequest}) {
    return _fakeModule.getBind<T>(params, typesInRequest: typesInRequest);
  }

  @override
  List<String> get paths => [this.runtimeType.toString()];

  @override
  bool remove<T>() {
    return _fakeModule.remove<T>();
  }

  @override
  void instance() {
    _fakeModule.instance();
  }

  @override
  List<Router> get routers => null;

  @override
  Widget build(BuildContext context) {
    return ModularProvider(
      module: this,
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

class ModularProvider extends StatefulWidget {
  final ChildModule module;
  final Widget child;

  const ModularProvider({Key key, this.module, this.child}) : super(key: key);

  @override
  _ModularProviderState createState() => _ModularProviderState();
}

class _ModularProviderState extends State<ModularProvider> {
  @override
  void initState() {
    super.initState();
    Modular.addCoreInit(widget.module);
    _debugPrintModular("-- ${widget.module.runtimeType} INITIALIZED");
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    Modular.removeModule(widget.module);
    _debugPrintModular("-- ${widget.module.runtimeType} DISPOSED");
  }
}
