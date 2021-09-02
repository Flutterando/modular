import 'package:flutter/widgets.dart';
import 'package:flutter_modular/src/domain/usecases/bind_module.dart';
import 'package:flutter_modular/src/domain/usecases/unbind_module.dart';
import 'package:flutter_modular/src/flutter_modular_module.dart';
import 'package:flutter_modular/src/presenter/models/bind.dart';
import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:modular_core/modular_core.dart';

abstract class WidgetModule extends StatelessWidget implements BindContext {
  Widget get view;

  @override
  List<Bind> get binds => const [];

  @override
  Future<void> isReady() {
    return _fakeModule.isReady();
  }

  late final _FakeModule _fakeModule = _FakeModule(binds: binds);

  WidgetModule({Key? key}) : super(key: key);

  @override
  T? getBind<T extends Object>(Injector injector) {
    return _fakeModule.getBind<T>(injector);
  }

  @override
  bool remove<T>() {
    return _fakeModule.remove<T>();
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

class _FakeModule extends BindContextImpl {
  _FakeModule({required this.binds});

  @override
  late final List<Bind> binds;
}

class ModularProvider<T extends BindContext> extends StatefulWidget {
  final BindContext module;
  final Widget child;

  const ModularProvider({Key? key, required this.module, required this.child}) : super(key: key);

  @override
  _ModularProviderState createState() => _ModularProviderState<T>();
}

class _ModularProviderState<T extends BindContext> extends State<ModularProvider> {
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
    injector.get<UnbindModule>().call<T>();
  }
}
