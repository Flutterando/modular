import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../flutter_modular.dart';
import '../core/interfaces/modular_interface.dart';
import '../core/interfaces/module.dart';
import 'modular_impl.dart';
import 'navigation/modular_route_information_parser.dart';
import 'navigation/modular_router_delegate.dart';
import 'navigation/router_outlet_delegate.dart';

class ModularFlags {
  bool experimentalNotAllowedParentBinds;
  bool isCupertino;
  ModularFlags({
    this.experimentalNotAllowedParentBinds = false,
    this.isCupertino = false,
  });
}

final _modularFlags = ModularFlags();

final Map<String, Module> _injectMap = {};

late final _routeInformationParser = ModularRouteInformationParser();
late final _routerDelegate = ModularRouterDelegate(parser: _routeInformationParser, injectMap: _injectMap);

// ignore: non_constant_identifier_names
final ModularInterface Modular = ModularImpl(routerDelegate: _routerDelegate, injectMap: _injectMap, flags: _modularFlags);

@visibleForTesting
String initialRouteDeclaratedInMaterialApp = '/';

extension ModularExtensionMaterial on MaterialApp {
  MaterialApp modular() {
    _routerDelegate.setObserver(navigatorObservers ?? <NavigatorObserver>[]);
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

extension ModularExtensionCupertino on CupertinoApp {
  CupertinoApp modular() {
    _routerDelegate.setObserver(navigatorObservers ?? <NavigatorObserver>[]);

    _modularFlags.isCupertino = true;
    initialRouteDeclaratedInMaterialApp = initialRoute ?? '/';

    final app = CupertinoApp.router(
      key: key,
      routeInformationProvider: routeInformationProvider,
      backButtonDispatcher: backButtonDispatcher,
      builder: builder,
      title: title,
      onGenerateTitle: onGenerateTitle,
      color: color,
      theme: theme,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
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
    Modular.to.addListener(_listener);
  }

  void _listener() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = Router.of(context);
    _backButtonDispatcher = router.backButtonDispatcher!.createChildBackButtonDispatcher();
  }

  @override
  void dispose() {
    super.dispose();
    Modular.to.removeListener(_listener);
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
