import 'dart:async';

import 'package:auto_injector/auto_injector.dart';
import 'package:flutter/widgets.dart';

/// Registrar for PAGE-SCOPED state, used in `route(provide: (scoped) {...})`.
///
/// Each registration becomes a factory built in a page-local injector at mount
/// (deps resolved from the module injector), provided reactively via
/// `InheritedNotifier`, and disposed at unmount.
class Scoped {
  final List<ScopedSpec> _specs = [];

  List<ScopedSpec> get specs => List.unmodifiable(_specs);

  /// Registers a [ChangeNotifier] view model, scoped to the page (built in the
  /// page-local injector, provided via `InheritedNotifier`, `dispose()`d on
  /// unmount). The bound is [ChangeNotifier] — NOT [Listenable] — precisely so
  /// the dispose is guaranteed: a bare `Listenable` has no `dispose`, which
  /// would make resource cleanup silently best-effort.
  void addChangeNotifier<T extends ChangeNotifier>(Function constructor) {
    _specs.add(_ChangeNotifierSpec<T>(constructor));
  }

  /// Registers a NON-REACTIVE [Disposable], scoped to the page. It is built in
  /// the page-local injector (one instance per mount, so view models can depend
  /// on it) and `dispose()`d on unmount. Use this for resources that need
  /// lifecycle but no reactivity — a socket, a subscription manager, a
  /// use-case holding a connection. Reactivity ([ChangeNotifier]) and lifecycle
  /// ([Disposable]) are thus independent: a thing can have either, both, or
  /// neither.
  void addDisposable<T extends Disposable>(Function constructor) {
    _specs.add(_DisposableSpec<T>(constructor));
  }

  /// Registers stream-backed state. The latest value is exposed via
  /// `context.watch<StreamValue<T>>().value`.
  void addStream<T>(Stream<T> Function() create) {
    _specs.add(_StreamSpec<T>(create));
  }
}

/// A page-scoped resource that needs cleanup but is NOT reactive. Implement it
/// on any class and register it via [Scoped.addDisposable] to have it built in
/// the page-local injector and `dispose()`d when the page leaves the stack —
/// even though it is not a [Listenable]/[ChangeNotifier].
abstract interface class Disposable {
  void dispose();
}

/// Internal: one provided unit (register / resolve / wrap / dispose), typed.
abstract class ScopedSpec {
  Type get type;
  void register(AutoInjector injector);
  Object resolve(AutoInjector injector);
  Widget wrap(Object instance, Widget child);
  void dispose(Object instance);
}

class _ChangeNotifierSpec<T extends ChangeNotifier> implements ScopedSpec {
  _ChangeNotifierSpec(this.constructor);

  final Function constructor;

  @override
  Type get type => T;

  @override
  void register(AutoInjector injector) => injector.add<T>(constructor);

  @override
  Object resolve(AutoInjector injector) => injector.get<T>();

  @override
  Widget wrap(Object instance, Widget child) =>
      _VMInherited<T>(notifier: instance as T, child: child);

  @override
  void dispose(Object instance) => (instance as ChangeNotifier).dispose();
}

/// A non-reactive, page-scoped [Disposable]: registered as a per-page singleton
/// (shared with any view model that injects it), NOT provided through an
/// `InheritedNotifier` (nothing to listen to), and `dispose()`d on unmount.
class _DisposableSpec<T extends Disposable> implements ScopedSpec {
  _DisposableSpec(this.constructor);

  final Function constructor;

  @override
  Type get type => T;

  @override
  void register(AutoInjector injector) =>
      injector.addLazySingleton<T>(constructor);

  @override
  Object resolve(AutoInjector injector) => injector.get<T>();

  @override
  Widget wrap(Object instance, Widget child) => child;

  @override
  void dispose(Object instance) => (instance as Disposable).dispose();
}

/// A [ChangeNotifier] holding the latest value emitted by a [Stream].
class StreamValue<T> extends ChangeNotifier {
  StreamValue(Stream<T> stream) {
    _sub = stream.listen((event) {
      _value = event;
      notifyListeners();
    });
  }

  late final StreamSubscription<T> _sub;
  T? _value;

  T? get value => _value;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _StreamSpec<T> implements ScopedSpec {
  _StreamSpec(this.create);

  final Stream<T> Function() create;

  @override
  Type get type => StreamValue<T>;

  @override
  void register(AutoInjector injector) {}

  @override
  Object resolve(AutoInjector injector) => StreamValue<T>(create());

  @override
  Widget wrap(Object instance, Widget child) => _VMInherited<StreamValue<T>>(
    notifier: instance as StreamValue<T>,
    child: child,
  );

  @override
  void dispose(Object instance) => (instance as StreamValue<T>).dispose();
}

class _VMInherited<T extends Listenable> extends InheritedNotifier<T> {
  const _VMInherited({required super.notifier, required super.child});
}

/// Wraps a page subtree: builds the page-scoped instances in a page-local
/// injector (deps resolved from [parent], the module injector), provides them
/// via nested `InheritedNotifier`s, and disposes them on unmount.
///
/// The page-local injector is NOT disposed (that would cascade to the shared
/// [parent]); the instances are disposed individually.
class ScopedHost extends StatefulWidget {
  const ScopedHost({
    required this.provide,
    required this.parent,
    required this.child,
    super.key,
  });

  final void Function(Scoped scoped) provide;
  final AutoInjector parent;
  final Widget child;

  @override
  State<ScopedHost> createState() => _ScopedHostState();
}

class _ScopedHostState extends State<ScopedHost> {
  late final List<ScopedSpec> _specs;
  final Map<Type, Object> _instances = {};

  @override
  void initState() {
    super.initState();
    final scoped = Scoped();
    widget.provide(scoped);
    _specs = scoped.specs;

    final injector = AutoInjector()..addInjector(widget.parent);
    for (final spec in _specs) {
      spec.register(injector);
    }
    injector.commit();
    for (final spec in _specs) {
      _instances[spec.type] = spec.resolve(injector);
    }
  }

  @override
  void dispose() {
    for (final spec in _specs) {
      final instance = _instances[spec.type];
      if (instance != null) spec.dispose(instance);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var result = widget.child;
    for (final spec in _specs.reversed) {
      result = spec.wrap(_instances[spec.type]!, result);
    }
    return result;
  }
}

/// Page-scoped state access from any descendant of the page.
extension ModularStateX on BuildContext {
  /// Reactively reads a page-scoped [Listenable] (rebuilds on notify).
  T watch<T extends Listenable>() {
    final inherited = dependOnInheritedWidgetOfExactType<_VMInherited<T>>();
    final notifier = inherited?.notifier;
    if (notifier == null) {
      throw FlutterError('context.watch<$T>(): no scoped $T provided.');
    }
    return notifier;
  }

  /// Reads a page-scoped [Listenable] WITHOUT subscribing to rebuilds.
  T read<T extends Listenable>() {
    final element = getElementForInheritedWidgetOfExactType<_VMInherited<T>>();
    final notifier = (element?.widget as _VMInherited<T>?)?.notifier;
    if (notifier == null) {
      throw FlutterError('context.read<$T>(): no scoped $T provided.');
    }
    return notifier;
  }
}
