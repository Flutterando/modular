import 'package:flutter/material.dart';

import '../flutter_modular.dart';
import 'delegates/modular_route_information_parser.dart';
import 'delegates/modular_router_delegate.dart';
import 'interfaces/child_module.dart';
import 'interfaces/modular_interface.dart';
import 'modular_impl.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final Map<String, ChildModule> _injectMap = {};

final routeInformationParser = ModularRouteInformationParser();
final routerDelegate = ModularRouterDelegate(
  _navigatorKey,
  routeInformationParser,
  _injectMap,
);

// ignore: non_constant_identifier_names
final ModularInterface Modular = ModularImpl(
  routerDelegate: routerDelegate,
  injectMap: _injectMap,
);

extension ModularExtension on MaterialApp {
  MaterialApp modular() {
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
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
    );

    return app;
  }
}
