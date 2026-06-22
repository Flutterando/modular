import 'package:flutter/widgets.dart';

import '../route/route_state.dart';
import 'modular_router_delegate.dart';
import 'outlet.dart';
import 'route_resolver.dart';

/// Navigation from any widget.
///
/// `pushNamed` targets the nearest enclosing [RouterOutlet] (so the parent
/// shell persists); if there is none, it pushes the root delegate's stack. It
/// returns a `Future` that completes with the value passed to the matching
/// `pop(result)`. Pass an arbitrary object with `arguments:` and read it back
/// from `RouteState.arguments`.
///
/// Paths may be RELATIVE to the route this context sits on: `dashboard` or
/// `./dashboard` from `/home` both target `/home/dashboard`, and `../x` climbs
/// a level. A leading `/` makes it absolute. See [resolveRoute].
extension ModularNavigationX on BuildContext {
  /// Resolves a relative [path] against the route this context is on; absolute
  /// paths (leading `/`) pass through unchanged.
  String _resolve(String path) =>
      resolveRoute(path, locationOf(this) ?? Uri.parse('/')).toString();

  /// The app's current route as a full [RouteState] — `uri` (the stack base,
  /// refined by the active [RouterOutlet]), resolved path `params`, and the
  /// URL-base route's `arguments`.
  ///
  /// Reactive by default: a widget that reads this rebuilds when the app
  /// navigates, so route-aware chrome (a shell's active-tab highlight,
  /// breadcrumbs) DERIVES from the route instead of mirroring it in local
  /// state. Pass `listen: false` to read without subscribing (e.g. in a
  /// callback). Throws if there is no `ModularApp` / router above this context.
  ///
  /// Note: a widget INSIDE the active route subtree sees the same state as its
  /// `builder`'s `(ctx, state)`; this also reaches chrome OUTSIDE that subtree
  /// (beside an outlet), which the builder arg cannot. `arguments` here is the
  /// URL-base route's — nested-outlet / pushed (modal-like) args stay out of
  /// the URL by design and are read from their own builder's state.
  RouteState routeState({bool listen = true}) {
    final state = RouteStateScope.of(this, listen: listen);
    if (state == null) {
      throw FlutterError(
        'context.routeState: no ModularRouterDelegate found in the tree.',
      );
    }
    return state;
  }

  Future<T?> pushNamed<T extends Object?>(String path, {Object? arguments}) {
    final target = _resolve(path);
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.handles(target)) {
      return outlet.push<T>(target, arguments: arguments);
    }
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate) {
      return delegate.pushNamed<T>(target, arguments: arguments);
    }
    throw FlutterError(
      'context.pushNamed: no outlet or ModularRouterDelegate found.',
    );
  }

  /// Whether [pop] would do something — the nearest [RouterOutlet] or the root
  /// delegate has a route to pop. Use it to show a back button on a mounted
  /// module's INDEX page: that page is the sole entry of its outlet's nested
  /// Navigator, so `AppBar(automaticallyImplyLeading:)` can't see the root
  /// stack underneath and shows no arrow on its own.
  bool canPop() {
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.canPop) return true;
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate && delegate.canPop) return true;
    return Navigator.of(this).canPop();
  }

  /// Pops the current route with an optional [result] delivered to the
  /// `pushNamed` future. Targets the nearest poppable [RouterOutlet], else the
  /// root delegate, else the nearest [Navigator].
  void pop<T extends Object?>([T? result]) {
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.canPop) {
      outlet.pop<T>(result);
      return;
    }
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate && delegate.canPop) {
      delegate.pop<T>(result);
      return;
    }
    Navigator.of(this).pop<T>(result);
  }

  /// Pops the current route only if possible; returns whether it did.
  bool maybePop<T extends Object?>([T? result]) {
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.canPop) return outlet.maybePop<T>(result);
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate) return delegate.maybePop<T>(result);
    return false;
  }

  /// REPLACES the target's whole stack with [path] (resets history). Targets
  /// the nearest [RouterOutlet] whose subtree owns [path] — so in a shell it
  /// swaps the body (tab switch) — otherwise the root delegate (reset the app).
  /// This is the v7 unification of 6.x's `navigate` + `pushNavigate`.
  void navigate(String path, {Object? arguments}) {
    final target = _resolve(path);
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.handles(target)) {
      outlet.navigate(target, arguments: arguments);
      return;
    }
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate) {
      delegate.navigate(target, arguments: arguments);
      return;
    }
    throw FlutterError(
      'context.navigate: no outlet or ModularRouterDelegate found.',
    );
  }

  /// Replaces the TOP route with [path] (no back to the replaced one); the
  /// returned `Future` completes with the new route's pop result.
  Future<T?> replace<T extends Object?>(String path, {Object? arguments}) {
    final target = _resolve(path);
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.handles(target)) {
      return outlet.replace<T>(target, arguments: arguments);
    }
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate) {
      return delegate.replace<T>(target, arguments: arguments);
    }
    throw FlutterError(
      'context.replace: no outlet or ModularRouterDelegate found.',
    );
  }

  /// Pops repeatedly until [predicate] holds for the top route. Targets the
  /// nearest poppable [RouterOutlet], else the root delegate.
  void popUntil(bool Function(RouteState state) predicate) {
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.canPop) {
      outlet.popUntil(predicate);
      return;
    }
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate) delegate.popUntil(predicate);
  }

  /// Pops the current route delivering [result] to its `pushNamed` future, then
  /// pushes [path]. Dispatches like [pushNamed].
  Future<T?> popAndPushNamed<T extends Object?>(
    String path, {
    Object? result,
    Object? arguments,
  }) {
    final target = _resolve(path);
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.handles(target)) {
      return outlet.popAndPushNamed<T>(
        target,
        result: result,
        arguments: arguments,
      );
    }
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate) {
      return delegate.popAndPushNamed<T>(
        target,
        result: result,
        arguments: arguments,
      );
    }
    throw FlutterError(
      'context.popAndPushNamed: no outlet or ModularRouterDelegate found.',
    );
  }

  /// Pushes [path], then removes the routes beneath it until [predicate] holds.
  /// Dispatches like [pushNamed].
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String path,
    bool Function(RouteState state) predicate, {
    Object? arguments,
  }) {
    final target = _resolve(path);
    final outlet = RouterOutlet.of(this);
    if (outlet != null && outlet.handles(target)) {
      return outlet.pushNamedAndRemoveUntil<T>(
        target,
        predicate,
        arguments: arguments,
      );
    }
    final delegate = Router.of(this).routerDelegate;
    if (delegate is ModularRouterDelegate) {
      return delegate.pushNamedAndRemoveUntil<T>(
        target,
        predicate,
        arguments: arguments,
      );
    }
    throw FlutterError(
      'context.pushNamedAndRemoveUntil: no outlet or ModularRouterDelegate '
      'found.',
    );
  }
}
