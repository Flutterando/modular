import 'package:flutter/widgets.dart';

import '../../../flutter_modular.dart';
import '../../core/interfaces/module.dart';
import '../../core/models/bind.dart';
import '../modular_base.dart';

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

abstract class WidgetModule extends StatelessWidget implements Module {
  Widget get view;

  @override
  Future<void> isReady() {
    return _fakeModule.isReady();
  }

  @override
  List get instanciatedSingletons => [];

  @visibleForTesting
  @override
  final List<ModularRoute> routes = const [];

  final _FakeModule _fakeModule = _FakeModule();

  WidgetModule() {
    // ignore: invalid_use_of_visible_for_testing_member
    _fakeModule.changeBinds(binds);
  }

  @override
  T? getInjectedBind<T>([Type? type]) {
    return _fakeModule.getInjectedBind(type);
  }

  @override
  void changeBinds(List<Bind> b) {
    // ignore: invalid_use_of_visible_for_testing_member
    _fakeModule.changeBinds(b);
  }

  @override
  void cleanInjects() {
    _fakeModule.cleanInjects();
  }

  @override
  T? getBind<T extends Object>({Map<String, dynamic>? params, List<Type> typesInRequest = const []}) {
    return _fakeModule.getBind<T>(typesInRequest: typesInRequest);
  }

  @override
  List<String> get paths => [runtimeType.toString()];

  @override
  bool remove<T>() {
    return _fakeModule.remove<T>();
  }

  @override
  void instance(List binds) {
    _fakeModule.instance(binds);
  }

  @override
  final List<Module> imports = const [];

  @override
  Widget build(BuildContext context) {
    return ModularProvider(
      module: this,
      child: view,
    );
  }
}

class _FakeModule extends Module {
  final List<Bind>? bindsInject;

  _FakeModule({this.bindsInject}) {
    paths.add(runtimeType.toString());
  }

  @override
  late final List<Bind> binds = bindsInject ?? [];

  @override
  final List<ModularRoute> routes = [];
}

class ModularProvider extends StatefulWidget {
  final Module module;
  final Widget child;

  const ModularProvider({Key? key, required this.module, required this.child}) : super(key: key);

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
