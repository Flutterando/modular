import 'package:flutter/widgets.dart';
import '../../core/inject/bind.dart';
import '../../core/models/modular_route.dart';
import '../../core/modules/child_module.dart';

import '../modular_base.dart';

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

abstract class WidgetModule extends StatelessWidget implements ChildModule {
  Widget get view;

  final _FakeModule _fakeModule = _FakeModule();

  WidgetModule() {
    _fakeModule.changeBinds(binds);
  }

  @override
  void changeBinds(List<Bind> b) {
    _fakeModule.changeBinds(b);
  }

  @override
  void cleanInjects() {
    _fakeModule.cleanInjects();
  }

  @override
  T? getBind<T>(
      {Map<String, dynamic>? params, List<Type> typesInRequest = const []}) {
    return _fakeModule.getBind<T>(
        params: params, typesInRequest: typesInRequest);
  }

  @override
  List<String> get paths => [runtimeType.toString()];

  @override
  bool remove<T>() {
    return _fakeModule.remove<T>();
  }

  @override
  void instance() {
    _fakeModule.instance();
  }

  @override
  List<ModularRoute> routers = const [];

  @override
  Widget build(BuildContext context) {
    return ModularProvider(
      module: this,
      child: view,
    );
  }
}

class _FakeModule extends ChildModule {
  final List<Bind>? bindsInject;

  _FakeModule({this.bindsInject}) {
    paths.add(runtimeType.toString());
  }

  @override
  List<Bind> get binds => bindsInject ?? [];

  @override
  List<ModularRoute> get routers => [];
}

class ModularProvider extends StatefulWidget {
  final ChildModule module;
  final Widget child;

  const ModularProvider({Key? key, required this.module, required this.child})
      : super(key: key);

  @override
  _ModularProviderState createState() => _ModularProviderState();
}

class _ModularProviderState extends State<ModularProvider> {
  @override
  void initState() {
    super.initState();
    // Modular.addCoreInit(widget.module);
    _debugPrintModular("-- ${widget.module.runtimeType} INITIALIZED");
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    // Modular.removeModule(widget.module);
    _debugPrintModular("-- ${widget.module.runtimeType} DISPOSED");
  }
}
