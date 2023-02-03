import 'package:flutter/widgets.dart';
import 'package:modular_core/modular_core.dart';

import '../../domain/usecases/bind_module.dart';
import '../../domain/usecases/unbind_module.dart';
import '../../flutter_modular_module.dart';

abstract class WidgetModule extends Widget {
  Widget build(BuildContext context);
  List<Bind> get binds;

  const WidgetModule({super.key});

  List<Module> get imports => const [];

  List<Bind> get exportedBinds => const [];

  @override
  Element createElement() => _ModuleElement(this);
}

class _ModuleImpl extends Module {
  @override
  final List<Bind> binds;
  @override
  final List<Bind> exportedBinds;
  @override
  final List<Module> imports;

  _ModuleImpl({
    this.binds = const [],
    this.exportedBinds = const [],
    this.imports = const [],
  });
}

class _ModuleElement extends ComponentElement {
  /// Creates an element that uses the given widget as its configuration.
  _ModuleElement(WidgetModule super.widget);

  @override
  Widget build() {
    final widgetModule = widget as WidgetModule;
    final child = widgetModule.build(this);
    return _ModularProvider(
      module: _ModuleImpl(
        binds: widgetModule.binds,
        exportedBinds: widgetModule.exportedBinds,
        imports: widgetModule.imports,
      ),
      tag: widgetModule.runtimeType.toString(),
      child: child,
    );
  }

  @override
  void update(StatelessWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget, 'widget == newWidget');
    rebuild(force: true);
  }
}

class _ModularProvider extends StatefulWidget {
  final Widget child;
  final Module module;
  final String tag;

  const _ModularProvider({
    Key? key,
    required this.child,
    required this.module,
    required this.tag,
  }) : super(key: key);

  @override
  _ModularProviderState createState() => _ModularProviderState();
}

class _ModularProviderState extends State<_ModularProvider> {
  @override
  void initState() {
    super.initState();
    injector.get<BindModule>().call(widget.module, widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    injector.get<UnbindModule>().call(type: widget.tag);
  }
}
