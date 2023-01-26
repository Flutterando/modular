import 'package:flutter/widgets.dart';
import 'package:modular_core/modular_core.dart';

import '../../domain/usecases/bind_module.dart';
import '../../domain/usecases/unbind_module.dart';
import '../../flutter_modular_module.dart';

abstract class WidgetModule extends StatelessWidget implements Module {
  Widget get view;

  @override
  List<Bind> get binds;

  const WidgetModule({Key? key}) : super(key: key);

  @override
  final List<Module> imports = const [];

  @override
  List<Bind> get exportedBinds => [];

  @override
  List<ModularRoute> get routes => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    return ModularProvider(
      module: this,
      child: view,
    );
  }
}

class ModularProvider<T extends Module> extends StatefulWidget {
  final Module module;
  final Widget child;

  const ModularProvider({Key? key, required this.module, required this.child})
      : super(key: key);

  @override
  _ModularProviderState createState() => _ModularProviderState<T>();
}

class _ModularProviderState<T extends Module> extends State<ModularProvider> {
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
