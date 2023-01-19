import 'package:flutter/widgets.dart';
import 'package:modular_core/modular_core.dart';

import '../../domain/usecases/bind_module.dart';
import '../../domain/usecases/unbind_module.dart';
import '../../flutter_modular_module.dart';
import '../models/bind.dart';
import '../models/module.dart';

abstract class WidgetModule extends StatelessWidget implements BindContextImpl {
  Widget get view;

  @override
  List<Bind> get binds;

  @override
  Future<void> isReady() {
    return _fakeModule.isReady();
  }

  late final _FakeModule _fakeModule = _FakeModule(binds: binds);

  WidgetModule({Key? key}) : super(key: key);

  @override
  BindEntry<T>? getBind<T extends Object>(Injector injector) {
    return _fakeModule.getBind<T>(injector);
  }

  @override
  bool remove<T>() {
    return _fakeModule.remove<T>();
  }

  @override
  final List<Module> imports = const [];

  @override
  List<BindEntry> get instanciatedSingletons =>
      _fakeModule.instanciatedSingletons;

  @override
  void instantiateSingletonBinds(
      List<BindEntry<Object>> singletons, Injector injector) {
    _fakeModule.instantiateSingletonBinds(singletons, injector);
  }

  @override
  bool removeScopedBind() {
    return _fakeModule.removeScopedBind();
  }

  @override
  // ignore: invalid_use_of_internal_member
  Set<String> get tags => _fakeModule.tags;

  @override
  void dispose() {
    _fakeModule.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModularProvider(
      module: this,
      child: view,
    );
  }

  @override
  void changeBinds(List<BindContract<Object>> newBinds) =>
      _fakeModule.changeBinds(newBinds);

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  List<BindContract<Object>> getProcessBinds() => _fakeModule.getProcessBinds();
}

class _FakeModule extends BindContextImpl {
  _FakeModule({required this.binds});

  @override
  late final List<Bind> binds;
}

class ModularProvider<T extends BindContext> extends StatefulWidget {
  final BindContext module;
  final Widget child;

  const ModularProvider({Key? key, required this.module, required this.child})
      : super(key: key);

  @override
  _ModularProviderState createState() => _ModularProviderState<T>();
}

class _ModularProviderState<T extends BindContext>
    extends State<ModularProvider> {
  @override
  void initState() {
    super.initState();
    injector.get<BindModule>().call(widget.module);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    injector.get<UnbindModule>().call<T>(type: widget.module.runtimeType);
  }
}
