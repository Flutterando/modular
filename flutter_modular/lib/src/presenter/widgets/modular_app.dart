import 'package:flutter/widgets.dart';
import '../../../flutter_modular.dart';

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
    return _ModularInherited(child: widget.child);
  }
}

typedef SelectCallback<T> = Function(T bind);

class _Register<T> {
  final T value;
  Type get type => T;
  final SelectCallback<T>? _select;

  _Register(this.value, this._select);

  dynamic getSelected() {
    final result = _select?.call(value);
    if (result != null) {
      return result;
    }
    return value;
  }

  @override
  bool operator ==(Object object) =>
      identical(this, object) ||
      object is _Register &&
          runtimeType == object.runtimeType &&
          type == object.type;

  @override
  int get hashCode => value.hashCode ^ type.hashCode;
}

class _ModularInherited extends InheritedWidget {
  const _ModularInherited({Key? key, required Widget child})
      : super(key: key, child: child);

  static T of<T extends Object>(BuildContext context,
      {bool listen = true, SelectCallback<T>? select}) {
    final entry = Modular.getBindEntry<T>();
    final bind = entry.bind as Bind;
    if (listen) {
      final registre = _Register<T>(entry.value, select ?? bind.onSelectorFunc);
      final inherited =
          context.dependOnInheritedWidgetOfExactType<_ModularInherited>(
              aspect: registre)!;
      inherited.updateShouldNotify(inherited);
    }

    return entry.value;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  @override
  InheritedElement createElement() => _InheritedModularElement(this);
}

class _InheritedModularElement extends InheritedElement {
  _InheritedModularElement(InheritedWidget widget) : super(widget);

  bool _dirty = false;

  Type? current;

  @override
  void updateDependencies(Element dependent, covariant _Register aspect) {
    var registers = getDependencies(dependent) as Set<_Register>?;

    registers ??= {};

    if (registers.contains(aspect)) {
      return;
    }

    final value = aspect.getSelected();

    if (value is Listenable) {
      value.addListener(() => _handleUpdate(aspect.type));
    } else if (value is Stream) {
      value.listen((event) => _handleUpdate(aspect.type));
    }
    registers.add(aspect);
    setDependencies(dependent, registers);
  }

  @override
  Widget build() {
    if (_dirty) notifyClients(widget);
    return super.build();
  }

  void _handleUpdate(Type type) {
    current = type;
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void notifyClients(covariant Widget oldWidget) {
    super.notifyClients(oldWidget as InheritedWidget);
    _dirty = false;
    current = null;
  }

  @override
  void notifyDependent(covariant InheritedWidget oldWidget, Element dependent) {
    var registers = getDependencies(dependent) as Set<_Register>?;
    registers ??= {};

    for (var register in registers) {
      if (register.type == current) {
        dependent.didChangeDependencies();
      }
    }
  }
}

extension ModularWatchExtension on BuildContext {
  /// Request an instance by [Type] and
  /// watch your changes
  ///
  /// SUPPORTED CLASS ([Listenable], [Stream]).
  T watch<T extends Object>([SelectCallback<T>? select]) {
    return _ModularInherited.of<T>(this, select: select);
  }

  /// Request an instance by [Type]
  T read<T extends Object>() {
    return _ModularInherited.of<T>(this, listen: false);
  }
}
