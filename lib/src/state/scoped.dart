import 'dart:async';

import 'package:auto_injector/auto_injector.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Registrar for PAGE-SCOPED state, used in `route(provide: (scoped) {...})`.
///
/// Each registration becomes a factory built in a page-local injector at mount
/// (deps resolved from the module injector), provided reactively via
/// `InheritedNotifier`, and disposed at unmount.
///
/// The rule is [addChangeNotifier] (reactive view model) and [addStream]
/// (stream-backed value). [addStreamable] and [addListenable] are escape
/// hatches for objects whose reactivity lives on a *property* (a BLoC/Cubit's
/// `stream`, a controller's `Listenable`); [add] is the simple non-reactive
/// registration.
class Scoped {
  final List<ScopedSpec> _specs = [];

  List<ScopedSpec> get specs => List.unmodifiable(_specs);

  /// Registers a [ChangeNotifier] view model, scoped to the page (built in the
  /// page-local injector, provided via `InheritedNotifier`, `dispose()`d on
  /// unmount). The bound is [ChangeNotifier] — NOT [Listenable] — precisely so
  /// the dispose is guaranteed: a bare `Listenable` has no `dispose`, which
  /// would make resource cleanup silently best-effort.
  ///
  /// This is the default reactive registration; it delegates to [addListenable]
  /// (the notifier is both the exposed value and the rebuild trigger).
  void addChangeNotifier<T extends ChangeNotifier>(Function constructor) {
    addListenable<T>(constructor, (vm) => vm, (vm) => vm.dispose());
  }

  /// Registers a reactive object whose rebuild source is a [Listenable]
  /// *property* rather than the object itself — the escape hatch for reactive
  /// types that are not a [ChangeNotifier]. `context.watch<T>()` returns the
  /// object; rebuilds are driven by the listenable from [select]; [dispose] is
  /// called on unmount.
  ///
  /// Prefer [addChangeNotifier] unless your type's reactivity lives on a
  /// property.
  void addListenable<T extends Object>(
    Function constructor,
    Listenable Function(T value) select,
    FutureOr<void> Function(T value) dispose,
  ) {
    _specs.add(_ListenableSpec<T>(constructor, select, dispose));
  }

  /// Registers a reactive object whose rebuild source is a [Stream] *property*
  /// — for BLoC/Cubit and the like. `context.watch<T>()` returns the object
  /// itself (read its synchronous state, e.g. `bloc.state`); rebuilds are
  /// driven by the stream from [select]; [dispose] (e.g. `(b) => b.close()`) is
  /// called on unmount.
  ///
  /// Prefer [addStream] when you only need the latest emitted value; reach for
  /// this when you want to expose the object (its methods and current state).
  void addStreamable<T extends Object>(
    Function constructor,
    Stream<Object?> Function(T value) select,
    FutureOr<void> Function(T value) dispose,
  ) {
    _specs.add(_StreamableSpec<T>(constructor, select, dispose));
  }

  /// Registers stream-backed state. The latest value is exposed via
  /// `context.watch<StreamValue<T>>().value`.
  void addStream<T>(Stream<T> Function() create) {
    _specs.add(_StreamSpec<T>(create));
  }

  /// Registers a NON-REACTIVE object, scoped to the page. It is built in the
  /// page-local injector (one instance per mount, so view models can depend on
  /// it) and exposed via `context.read`/`watch` (`watch` never rebuilds — there
  /// is no trigger). Use this for resources that need lifecycle but no
  /// reactivity — a socket, a subscription manager, a use-case holding a
  /// connection, a config object.
  ///
  /// If the instance implements [Disposable], its `dispose()` is **always**
  /// called on unmount — the instance can be any class, including a bloc that
  /// chose to implement [Disposable] (mapping `dispose` to `close`). Reactivity
  /// and lifecycle are thus independent: a thing can have either, both, or
  /// neither.
  void add<T extends Object>(Function constructor) {
    _specs.add(_SimpleSpec<T>(constructor));
  }
}

/// A page-scoped resource that needs cleanup. Implement it on any class and
/// register it via [Scoped.add] to have it built in the page-local injector and
/// `dispose()`d when the page leaves the stack — even though it is not a
/// [Listenable]/[ChangeNotifier].
abstract interface class Disposable {
  void dispose();
}

/// Internal: one provided unit (register / resolve / wrap / dispose), typed.
abstract class ScopedSpec {
  Type get type;
  void register(AutoInjector injector);
  Object resolve(AutoInjector injector);
  Widget wrap(Object instance, Widget child);

  /// May return a [Future] (e.g. a bloc's `close()`); the host fires it and
  /// forgets, since `State.dispose` is synchronous.
  FutureOr<void> dispose(Object instance);
}

/// A reactive object whose rebuild trigger is a [Listenable] — either the
/// object itself (via [Scoped.addChangeNotifier]) or one of its properties (via
/// [Scoped.addListenable]). Registered as a per-page singleton (shared with any
/// view model that injects it), provided via [_VMInherited], and disposed by
/// the caller-supplied callback on unmount.
class _ListenableSpec<T extends Object> implements ScopedSpec {
  _ListenableSpec(this.constructor, this.select, this.onDispose);

  final Function constructor;
  final Listenable Function(T value) select;
  final FutureOr<void> Function(T value) onDispose;

  Listenable? _trigger;

  @override
  Type get type => T;

  @override
  void register(AutoInjector injector) =>
      injector.addLazySingleton<T>(constructor);

  @override
  Object resolve(AutoInjector injector) {
    final value = injector.get<T>();
    _trigger = select(value);
    return value;
  }

  @override
  Widget wrap(Object instance, Widget child) =>
      _VMInherited<T>(value: instance as T, notifier: _trigger, child: child);

  @override
  FutureOr<void> dispose(Object instance) => onDispose(instance as T);
}

/// A reactive object whose rebuild trigger is a [Stream] property (a BLoC or
/// Cubit and the like). The stream drives an internal [_StreamTrigger]; the
/// object itself is what `watch<T>()` returns. Disposed by the caller-supplied
/// callback (e.g. `close()`) on unmount, after the subscription is cancelled.
class _StreamableSpec<T extends Object> implements ScopedSpec {
  _StreamableSpec(this.constructor, this.select, this.onDispose);

  final Function constructor;
  final Stream<Object?> Function(T value) select;
  final FutureOr<void> Function(T value) onDispose;

  _StreamTrigger? _trigger;

  @override
  Type get type => T;

  @override
  void register(AutoInjector injector) =>
      injector.addLazySingleton<T>(constructor);

  @override
  Object resolve(AutoInjector injector) {
    final value = injector.get<T>();
    _trigger = _StreamTrigger(select(value));
    return value;
  }

  @override
  Widget wrap(Object instance, Widget child) =>
      _VMInherited<T>(value: instance as T, notifier: _trigger, child: child);

  @override
  Future<void> dispose(Object instance) async {
    // Stop listening BEFORE the user closes the object, so no late emission
    // reaches the trigger during teardown.
    _trigger?.dispose();
    await onDispose(instance as T);
  }
}

/// A non-reactive, page-scoped object: registered as a per-page singleton
/// (shared with any view model that injects it), provided via [_VMInherited]
/// with a null trigger (readable but never rebuilding), and — if it implements
/// [Disposable] — `dispose()`d on unmount.
class _SimpleSpec<T extends Object> implements ScopedSpec {
  _SimpleSpec(this.constructor);

  final Function constructor;

  @override
  Type get type => T;

  @override
  void register(AutoInjector injector) =>
      injector.addLazySingleton<T>(constructor);

  @override
  Object resolve(AutoInjector injector) => injector.get<T>();

  @override
  Widget wrap(Object instance, Widget child) =>
      _VMInherited<T>(value: instance as T, child: child);

  @override
  void dispose(Object instance) {
    if (instance is Disposable) instance.dispose();
  }
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
  Widget wrap(Object instance, Widget child) {
    final streamValue = instance as StreamValue<T>;
    return _VMInherited<StreamValue<T>>(
      value: streamValue,
      notifier: streamValue,
      child: child,
    );
  }

  @override
  void dispose(Object instance) => (instance as StreamValue<T>).dispose();
}

/// Internal: adapts a [Stream] into a notify-only [Listenable] rebuild trigger.
/// It does NOT retain emitted values (unlike [StreamValue]) — it only notifies,
/// and cancels its subscription on dispose.
class _StreamTrigger extends ChangeNotifier {
  _StreamTrigger(Stream<Object?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Internal: provides a page-scoped [value] of any type [T], rebuilding
/// dependents when [notifier] (the trigger) fires.
///
/// For `ChangeNotifier`-style state, [value] and `notifier` are the same
/// object; for streamables they differ (the object vs. an internal
/// [_StreamTrigger]); for a non-reactive [Scoped.add], `notifier` is null and
/// dependents never rebuild. Decoupling the exposed value from the trigger is
/// what lets `watch<T>()` return a non-`Listenable` (e.g. a bloc).
class _VMInherited<T extends Object> extends InheritedNotifier<Listenable> {
  const _VMInherited({
    required this.value,
    super.notifier,
    required super.child,
  });

  final T value;

  @override
  InheritedElement createElement() => _VMInheritedElement<T>(this);
}

/// A selector aspect: given the current value, reports whether the value this
/// dependent derived from it has changed (and therefore needs a rebuild).
typedef _SelectorAspect<T> = bool Function(T value);

/// Per-dependent record of the selectors registered via `context.select<T>`.
/// [shouldClear] is flipped on by a microtask after each build so the next
/// build's first `select` call discards the previous build's stale selectors.
class _SelectDependency<T> {
  final List<_SelectorAspect<T>> selectors = [];
  bool shouldClear = false;
  bool clearScheduled = false;
}

/// Marker dependency for a `watch` dependent (notified on every trigger).
const Object _watchAll = Object();

/// Element for [_VMInherited]. It reproduces [InheritedNotifier]'s "rebuild
/// dependents when the trigger fires" behaviour, but adds per-dependent aspect
/// filtering so `context.select<T, R>` rebuilds a dependent ONLY when its
/// selected value changes — the method-based twin of the `Selector` widget. A
/// `watch` dependent (no aspect) is still notified on every trigger.
class _VMInheritedElement<T extends Object> extends InheritedElement {
  _VMInheritedElement(_VMInherited<T> widget) : super(widget) {
    widget.notifier?.addListener(_handleUpdate);
  }

  bool _dirty = false;

  _VMInherited<T> get _widget => widget as _VMInherited<T>;

  @override
  void update(_VMInherited<T> newWidget) {
    final oldNotifier = _widget.notifier;
    final newNotifier = newWidget.notifier;
    if (oldNotifier != newNotifier) {
      oldNotifier?.removeListener(_handleUpdate);
      newNotifier?.addListener(_handleUpdate);
    }
    super.update(newWidget);
  }

  void _handleUpdate() {
    _dirty = true;
    markNeedsBuild();
  }

  @override
  Widget build() {
    if (_dirty) notifyClients(_widget);
    return super.build();
  }

  @override
  void notifyClients(InheritedNotifier<Listenable> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  void unmount() {
    _widget.notifier?.removeListener(_handleUpdate);
    super.unmount();
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final current = getDependencies(dependent);
    // Already subscribed to the whole value (a prior `watch`) — selectors are
    // irrelevant from here on; stay subscribed to everything.
    if (current != null && current is! _SelectDependency<T>) return;

    if (aspect is _SelectorAspect<T>) {
      final dep = (current as _SelectDependency<T>?) ?? _SelectDependency<T>();
      if (dep.shouldClear) {
        dep.shouldClear = false;
        dep.selectors.clear();
      }
      if (!dep.clearScheduled) {
        dep.clearScheduled = true;
        scheduleMicrotask(() {
          dep
            ..clearScheduled = false
            ..shouldClear = true;
        });
      }
      dep.selectors.add(aspect);
      setDependencies(dependent, dep);
    } else {
      // `watch`: no aspect — depend on every notification.
      setDependencies(dependent, _watchAll);
    }
  }

  @override
  void notifyDependent(InheritedWidget oldWidget, Element dependent) {
    final dependencies = getDependencies(dependent);
    if (dependencies is _SelectDependency<T>) {
      final value = _widget.value;
      for (final hasChanged in dependencies.selectors) {
        if (hasChanged(value)) {
          dependent.didChangeDependencies();
          return;
        }
      }
      return;
    }
    // `watch` (or default) — always rebuild.
    dependent.didChangeDependencies();
  }
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

    final seen = <Type>{};
    for (final spec in _specs) {
      if (!seen.add(spec.type)) {
        throw FlutterError(
          'Scoped: type ${spec.type} registered more than once in the same '
          'route. Each page-scoped type must be unique.',
        );
      }
    }

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
      if (instance != null) {
        final result = spec.dispose(instance);
        if (result is Future) unawaited(result);
      }
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
  /// Reactively reads a page-scoped value of type [T] (rebuilds when its
  /// trigger fires). For [Scoped.addStreamable]/[Scoped.addListenable], [T] is
  /// the object itself.
  T watch<T extends Object>() {
    final inherited = dependOnInheritedWidgetOfExactType<_VMInherited<T>>();
    if (inherited == null) {
      throw FlutterError('context.watch<$T>(): no scoped $T provided.');
    }
    return inherited.value;
  }

  /// Reactively reads a value [R] DERIVED from a page-scoped [T], rebuilding
  /// only when the selected value changes (compared with `==`). It is the
  /// method-based twin of the `Selector` widget — call it inside `build` to
  /// scope a rebuild to exactly what a widget uses:
  ///
  /// ```dart
  /// final name = context.select<UserVM, String>((vm) => vm.name);
  /// ```
  ///
  /// Mirrors `context.select` from `provider`, easing migration. Like there,
  /// only call it from `build` (never in `initState`/`didChangeDependencies`).
  R select<T extends Object, R>(R Function(T value) selector) {
    final element = getElementForInheritedWidgetOfExactType<_VMInherited<T>>();
    if (element == null) {
      throw FlutterError('context.select<$T, $R>(): no scoped $T provided.');
    }
    final selected = selector((element.widget as _VMInherited<T>).value);
    dependOnInheritedElement(
      element,
      aspect: (T value) => selector(value) != selected,
    );
    return selected;
  }

  /// Reads a page-scoped value of type [T] WITHOUT subscribing to rebuilds.
  T read<T extends Object>() {
    final element = getElementForInheritedWidgetOfExactType<_VMInherited<T>>();
    final inherited = element?.widget as _VMInherited<T>?;
    if (inherited == null) {
      throw FlutterError('context.read<$T>(): no scoped $T provided.');
    }
    return inherited.value;
  }

  /// Internal: the (value, trigger) pair backing a page-scoped [T], used by
  /// `Consumer`/`Selector` to subscribe to the trigger while exposing the value.
  @internal
  ({T value, Listenable? trigger}) scopedPair<T extends Object>() {
    final element = getElementForInheritedWidgetOfExactType<_VMInherited<T>>();
    final inherited = element?.widget as _VMInherited<T>?;
    if (inherited == null) {
      throw FlutterError('no scoped $T provided.');
    }
    return (value: inherited.value, trigger: inherited.notifier);
  }
}
