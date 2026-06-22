import 'package:flutter/widgets.dart';

import '../module/module.dart';
import '../navigation/modular_router_config.dart';
import '../route/route_state.dart';
import '../state/scoped.dart';

/// The root widget of a Modular app. It bootstraps [module] once (collecting
/// its routes + DI), owns the resulting injector, builds the [RouterConfig],
/// and — sitting ABOVE the `MaterialApp` — hosts optional APP-SCOPED state via
/// [provide]. That position is exactly what lets an app-global view model
/// (theme, locale, session) rebuild the `MaterialApp` itself, which page-scoped
/// state (living below the `Navigator`) cannot reach.
///
/// The [child] reads the router config with [ModularApp.routerConfigOf] and any
/// app-scoped view model with `context.watch`/`read` — same `Scoped` mechanism
/// as a route's `provide`, only anchored at the app instead of the page:
///
/// ```dart
/// void main() => runApp(
///   ModularApp(
///     module: appModule,
///     provide: (s) => s.addChangeNotifier<ThemeViewModel>(ThemeViewModel.new),
///     child: const AppRoot(),
///   ),
/// );
///
/// class AppRoot extends StatelessWidget {
///   const AppRoot({super.key});
///   @override
///   Widget build(BuildContext context) {
///     final theme = context.watch<ThemeViewModel>(); // above MaterialApp
///     return MaterialApp.router(
///       themeMode: theme.mode,
///       routerConfig: ModularApp.routerConfigOf(context),
///     );
///   }
/// }
/// ```
class ModularApp extends StatefulWidget {
  const ModularApp({
    required this.module,
    required this.child,
    this.provide,
    this.initialRoute = '/',
    this.navigatorKey,
    this.navigatorObservers = const [],
    super.key,
  });

  /// The root module: its routes + DI become the whole app graph.
  final Module module;

  /// Typically a `MaterialApp.router` that reads [routerConfigOf] and watches
  /// any app-scoped state declared in [provide].
  final Widget child;

  /// Optional APP-SCOPED state, declared like a route's `provide` but anchored
  /// above the [child] (and thus above the `MaterialApp`), so it can drive the
  /// app's theme/locale.
  final void Function(Scoped scoped)? provide;

  /// The first route shown — used when the platform reports no deep link
  /// (the bare `/`). A real entry URL (web refresh, app link) overrides it.
  final String initialRoute;

  /// Optional key for the root [Navigator], for imperative access from outside
  /// the widget tree (e.g. showing a global dialog). A fresh key is used if
  /// omitted.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Observers attached to the root [Navigator] — analytics, a `RouteObserver`
  /// for route-aware widgets, etc.
  final List<NavigatorObserver> navigatorObservers;

  /// The router config built by the nearest enclosing [ModularApp].
  static RouterConfig<RouteState> routerConfigOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_ModularAppScope>();
    if (scope == null) {
      throw FlutterError(
        'ModularApp.routerConfigOf: no ModularApp ancestor found.',
      );
    }
    return scope.routerConfig;
  }

  @override
  State<ModularApp> createState() => _ModularAppState();
}

class _ModularAppState extends State<ModularApp> {
  late final ModularBootstrap _boot = bootstrapModule(widget.module);
  late final RouterConfig<RouteState> _routerConfig = modularRouterConfig(
    _boot.routes,
    injector: _boot.injector,
    manager: _boot.manager,
    initialRoute: widget.initialRoute,
    navigatorKey: widget.navigatorKey,
    observers: widget.navigatorObservers,
  );

  @override
  Widget build(BuildContext context) {
    Widget child = _ModularAppScope(
      routerConfig: _routerConfig,
      child: widget.child,
    );
    final provide = widget.provide;
    if (provide != null) {
      child = ScopedHost(
        provide: provide,
        parent: _boot.injector,
        child: child,
      );
    }
    return child;
  }
}

/// Exposes the [RouterConfig] built by [ModularApp] to its descendants.
class _ModularAppScope extends InheritedWidget {
  const _ModularAppScope({required this.routerConfig, required super.child});

  final RouterConfig<RouteState> routerConfig;

  @override
  bool updateShouldNotify(_ModularAppScope oldWidget) =>
      routerConfig != oldWidget.routerConfig;
}
