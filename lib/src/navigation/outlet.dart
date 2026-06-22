import 'dart:async';

import 'package:auto_injector/auto_injector.dart';
import 'package:flutter/material.dart';

import '../route/modular_route.dart';
import '../route/route_state.dart';
import '../state/scoped.dart';
import 'modular_router_delegate.dart';
import 'transition.dart';

/// Builds one level of a matched route chain: the route's page (with its
/// page-scoped `provide`), wrapped in an [_OutletScope] that carries the
/// REMAINING chain — and any [arguments] — to any [RouterOutlet] inside it.
Widget buildRouteLevel({
  required List<RouteLevel> chain,
  required int index,
  required AutoInjector injector,
  required Uri uri,
  required Map<String, String> params,
  required RouteCollection routes,
  Object? arguments,
}) {
  final level = chain[index];
  final merged = {...params, ...level.params};
  final state = RouteState(uri: uri, params: merged, arguments: arguments);

  Widget page = Builder(builder: (ctx) => level.route.builder(ctx, state));
  final provide = level.route.provide;
  if (provide != null) {
    page = ScopedHost(provide: provide, parent: injector, child: page);
  }

  return _OutletScope(
    chain: chain,
    index: index + 1,
    injector: injector,
    uri: uri,
    params: merged,
    arguments: arguments,
    routes: routes,
    child: page,
  );
}

class _OutletScope extends InheritedWidget {
  const _OutletScope({
    required this.chain,
    required this.index,
    required this.injector,
    required this.uri,
    required this.params,
    required this.routes,
    required super.child,
    this.arguments,
  });

  final List<RouteLevel> chain;
  final int index;
  final AutoInjector injector;
  final Uri uri;
  final Map<String, String> params;
  final Object? arguments;
  final RouteCollection routes;

  static _OutletScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_OutletScope>();

  @override
  bool updateShouldNotify(_OutletScope oldWidget) =>
      index != oldWidget.index || !identical(chain, oldWidget.chain);
}

/// The URI of the route subtree [context] sits in — the base for resolving
/// relative navigation (`context.pushNamed('dashboard')`). Reads WITHOUT
/// subscribing (no rebuild on change); `null` above any route. Inside a
/// [RouterOutlet] this is the outlet's current sub-route, so relatives stay
/// scoped to the shell.
Uri? locationOf(BuildContext context) {
  final element = context
      .getElementForInheritedWidgetOfExactType<_OutletScope>();
  return (element?.widget as _OutletScope?)?.uri;
}

/// Renders the child route(s) of the current level in a REAL nested
/// [Navigator] — with its own push/pop sub-stack. Calling `context.pushNamed`
/// from inside an outlet targets THIS outlet, so the parent shell persists, and
/// its returned `Future` completes with the value passed to `pop(result)`.
/// Scope nests through it: a child's `context.watch` reaches the parent's VMs.
class RouterOutlet extends StatefulWidget {
  const RouterOutlet({super.key});

  /// The nearest enclosing outlet, for navigation targeting.
  static RouterOutletState? of(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<_OutletController>();
    return (element?.widget as _OutletController?)?.state;
  }

  @override
  State<RouterOutlet> createState() => RouterOutletState();
}

class RouterOutletState extends State<RouterOutlet> {
  late _OutletScope _scope;
  Uri? _seedUri;
  final List<_OutletEntry> _stack = [];
  int _seq = 0;

  /// Whether this outlet has a sub-route above its seed to pop.
  bool get canPop => _stack.length > 1;

  /// Whether [path] resolves WITHIN this outlet's subtree — i.e. its matched
  /// chain shares this outlet's ancestor prefix and has a level at this
  /// outlet's depth. If not (e.g. a sibling top-level route pushed from a
  /// module mounted at `/`), the push must bubble up to the root delegate.
  bool handles(String path) {
    final chain = _scope.routes.match(Uri.parse(path));
    if (chain == null || chain.length <= _scope.index) return false;
    for (var i = 0; i < _scope.index; i++) {
      if (!identical(chain[i].route, _scope.chain[i].route)) return false;
    }
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = _OutletScope.of(context)!;
    // (Re)seed the sub-stack when the top route (the scope URL) changes.
    if (_seedUri != _scope.uri) {
      _seedUri = _scope.uri;
      for (final e in _stack) {
        if (!e.completer.isCompleted) e.completer.complete(null);
      }
      _stack
        ..clear()
        ..add(_entry(_scope.uri, _scope.arguments));
    }
  }

  _OutletEntry _entry(Uri uri, Object? arguments) => _OutletEntry(
    uri,
    ValueKey('outlet-${identityHashCode(this)}-${_seq++}'),
    Completer<Object?>(),
    arguments,
  );

  /// Pushes [path] onto THIS outlet's sub-stack (the parent shell persists);
  /// the returned future completes with the value passed to `pop(result)`.
  Future<T?> push<T extends Object?>(String path, {Object? arguments}) {
    final entry = _entry(Uri.parse(path), arguments);
    setState(() => _stack.add(entry));
    _reportLocation();
    return entry.completer.future.then((value) => value as T?);
  }

  /// Pops this outlet's top sub-route, completing its `push` future.
  void pop<T extends Object?>([T? result]) {
    if (!canPop) return;
    _remove(_stack.last.key, result);
  }

  /// Pops this outlet's top sub-route if possible; returns whether it did.
  bool maybePop<T extends Object?>([T? result]) {
    if (!canPop) return false;
    _remove(_stack.last.key, result);
    return true;
  }

  /// Replaces this outlet's WHOLE sub-stack with [path] — the shell "navigate"
  /// (a bottom-bar tab switch swaps the body without stacking history).
  void navigate(String path, {Object? arguments}) {
    for (final entry in _stack) {
      if (!entry.completer.isCompleted) entry.completer.complete(null);
    }
    setState(() {
      _stack
        ..clear()
        ..add(_entry(Uri.parse(path), arguments));
    });
    _reportLocation();
  }

  /// Replaces this outlet's TOP sub-route with [path].
  Future<T?> replace<T extends Object?>(String path, {Object? arguments}) {
    if (_stack.isNotEmpty) {
      final top = _stack.removeLast();
      if (!top.completer.isCompleted) top.completer.complete(null);
    }
    final entry = _entry(Uri.parse(path), arguments);
    setState(() => _stack.add(entry));
    _reportLocation();
    return entry.completer.future.then((value) => value as T?);
  }

  /// Pops this outlet's sub-stack until [predicate] holds (or one remains).
  void popUntil(bool Function(RouteState state) predicate) {
    var changed = false;
    while (_stack.length > 1 &&
        !predicate(
          RouteState(uri: _stack.last.uri, arguments: _stack.last.arguments),
        )) {
      final top = _stack.removeLast();
      if (!top.completer.isCompleted) top.completer.complete(null);
      changed = true;
    }
    if (changed && mounted) setState(() {});
    _reportLocation();
  }

  /// Pops this outlet's top sub-route delivering [result], then pushes [path].
  Future<T?> popAndPushNamed<T extends Object?>(
    String path, {
    Object? result,
    Object? arguments,
  }) {
    if (_stack.isNotEmpty) {
      final top = _stack.removeLast();
      if (!top.completer.isCompleted) top.completer.complete(result);
    }
    final entry = _entry(Uri.parse(path), arguments);
    setState(() => _stack.add(entry));
    _reportLocation();
    return entry.completer.future.then((value) => value as T?);
  }

  /// Pushes [path] onto this outlet, then removes the sub-routes BENEATH it
  /// until [predicate] holds (or only the new one remains).
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String path,
    bool Function(RouteState state) predicate, {
    Object? arguments,
  }) {
    final entry = _entry(Uri.parse(path), arguments);
    _stack.add(entry);
    while (_stack.length > 1 &&
        !predicate(
          RouteState(
            uri: _stack[_stack.length - 2].uri,
            arguments: _stack[_stack.length - 2].arguments,
          ),
        )) {
      final removed = _stack.removeAt(_stack.length - 2);
      if (!removed.completer.isCompleted) removed.completer.complete(null);
    }
    setState(() {});
    _reportLocation();
    return entry.completer.future.then((value) => value as T?);
  }

  /// Reports this outlet's current base sub-route to the root delegate so the
  /// URL reflects the outlet (a tab switch shows up). A push/pop leaves the
  /// base unchanged, so it reports the same value and stays out of the URL.
  void _reportLocation() {
    if (_stack.isEmpty) return;
    final delegate = Router.maybeOf(context)?.routerDelegate;
    if (delegate is ModularRouterDelegate) {
      delegate.reportNestedLocation(_stack.first.uri);
    }
  }

  void _remove(Key? key, Object? result) {
    final index = _stack.indexWhere((e) => e.key == key);
    if (index == -1) return;
    final entry = _stack.removeAt(index);
    if (!entry.completer.isCompleted) entry.completer.complete(result);
    if (mounted) setState(() {});
    _reportLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (_scope.index >= _scope.chain.length) return const SizedBox.shrink();

    return _OutletController(
      state: this,
      child: Navigator(
        // ignore: deprecated_member_use
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          final settings = route.settings;
          if (settings is Page) _remove(settings.key, result);
          return true;
        },
        pages: [for (final entry in _stack) _page(entry)],
      ),
    );
  }

  Page<void> _page(_OutletEntry entry) {
    final chain = _scope.routes.match(entry.uri);
    if (chain == null || _scope.index >= chain.length) {
      return MaterialPage<void>(key: entry.key, child: const SizedBox.shrink());
    }
    final child = buildRouteLevel(
      chain: chain,
      index: _scope.index,
      injector: _scope.injector,
      uri: entry.uri,
      params: _scope.params,
      arguments: entry.arguments,
      routes: _scope.routes,
    );
    return buildTransitionPage(
      chain[_scope.index].route.transition,
      entry.key,
      child,
    );
  }
}

class _OutletEntry {
  _OutletEntry(this.uri, this.key, this.completer, this.arguments);
  final Uri uri;
  final LocalKey key;
  final Completer<Object?> completer;
  final Object? arguments;
}

/// Exposes the nearest [RouterOutletState] to the navigation extension.
class _OutletController extends InheritedWidget {
  const _OutletController({required this.state, required super.child});

  final RouterOutletState state;

  @override
  bool updateShouldNotify(_OutletController oldWidget) =>
      state != oldWidget.state;
}
