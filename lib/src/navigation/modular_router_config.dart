import 'package:auto_injector/auto_injector.dart';
import 'package:flutter/widgets.dart';

import '../module/module.dart';
import '../route/modular_route.dart';
import '../route/route_state.dart';
import 'modular_route_information_parser.dart';
import 'modular_router_delegate.dart';

/// Wires the Navigator 2.0 pieces into a [RouterConfig] for
/// `MaterialApp.router(routerConfig: ...)`.
///
/// Pass the [injector] (from `bootstrapModule`) when routes use `provide`, so
/// page-scoped view models can resolve their dependencies. Defaults to an empty
/// injector when omitted.
RouterConfig<RouteState> modularRouterConfig(
  RouteCollection routes, {
  AutoInjector? injector,
  ModuleManager? manager,
  String initialRoute = '/',
  GlobalKey<NavigatorState>? navigatorKey,
  List<NavigatorObserver> observers = const [],
}) {
  final inj = injector ?? (AutoInjector()..commit());
  return RouterConfig<RouteState>(
    routerDelegate: ModularRouterDelegate(
      routes,
      inj,
      manager: manager,
      navigatorKey: navigatorKey,
      observers: observers,
    ),
    routeInformationParser: ModularRouteInformationParser(),
    routeInformationProvider: PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: _initialUri(initialRoute)),
    ),
    backButtonDispatcher: RootBackButtonDispatcher(),
  );
}

/// The route to resolve on first build.
///
/// On the web (and anywhere the app boots from a deep link), the platform
/// hands us the real entry URL via `PlatformDispatcher.defaultRouteName` — e.g.
/// `/dashboard` after a refresh. We MUST honor it: `PlatformRouteInformationProvider`
/// seeds the `Router` from the `initialRouteInformation` we pass and does NOT
/// consult `defaultRouteName` itself, so hardcoding `/` here is exactly what
/// sends every deep link back to the root. When the platform reports the bare
/// `/` (no deep link), the app's configured [initialRoute] wins.
Uri _initialUri(String initialRoute) {
  final platformDefault =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  return Uri.parse(platformDefault == '/' ? initialRoute : platformDefault);
}
