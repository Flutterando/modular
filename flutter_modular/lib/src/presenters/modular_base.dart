import 'package:flutter/material.dart';

import '../../flutter_modular.dart';
import '../core/interfaces/modular_interface.dart';
import '../core/interfaces/module.dart';
import 'modular_impl.dart';
import 'navigation/modular_route_information_parser.dart';
import 'navigation/modular_router_delegate.dart';
import 'navigation/router_outlet_delegate.dart';

final Map<String, Module> _injectMap = {};

late final _routeInformationParser = ModularRouteInformationParser();
late final _routerDelegate = ModularRouterDelegate(
  _routeInformationParser,
  _injectMap,
);

// ignore: non_constant_identifier_names
final ModularInterface Modular = ModularImpl(
  routerDelegate: _routerDelegate,
  injectMap: _injectMap,
);

@visibleForTesting
String initialRouteDeclaratedInMaterialApp = '/';

extension ModularExtension on MaterialApp {
  MaterialApp modular() {
    initialRouteDeclaratedInMaterialApp = initialRoute ?? '/';

    final app = MaterialApp.router(
      key: key,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routeInformationProvider: routeInformationProvider,
      backButtonDispatcher: backButtonDispatcher,
      builder: builder,
      title: title,
      onGenerateTitle: onGenerateTitle,
      color: color,
      theme: theme,
      darkTheme: darkTheme,
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
      debugShowMaterialGrid: debugShowMaterialGrid,
      showPerformanceOverlay: showPerformanceOverlay,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
      showSemanticsDebugger: showSemanticsDebugger,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      shortcuts: shortcuts,
      actions: actions,
      restorationScopeId: restorationScopeId,
      routeInformationParser: _routeInformationParser,
      routerDelegate: _routerDelegate,
    );

    return app;
  }
}

class RouterOutlet extends StatefulWidget {
  @override
  _RouterOutletState createState() => _RouterOutletState();
}

class _RouterOutletState extends State<RouterOutlet> {
  late GlobalKey<NavigatorState> navigatorKey;
  late RouterOutletDelegate delegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    navigatorKey = GlobalKey<NavigatorState>();
    delegate = RouterOutletDelegate(_routerDelegate, navigatorKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = Router.of(context);
    _backButtonDispatcher = router.backButtonDispatcher!.createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    _backButtonDispatcher.takePriority();
    return Router(
      routerDelegate: delegate,
      backButtonDispatcher: _backButtonDispatcher,
    );
  }
}
