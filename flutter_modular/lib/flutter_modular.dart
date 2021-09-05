library flutter_modular;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/src/flutter_modular_module.dart';

import 'src/presenter/models/modular_navigator.dart';
import 'src/presenter/modular_base.dart';
import 'src/presenter/navigation/modular_page.dart';
import 'src/presenter/navigation/modular_route_information_parser.dart';
import 'src/presenter/navigation/modular_router_delegate.dart';
import 'src/presenter/navigation/router_outlet_delegate.dart';

export 'package:flutter_modular_annotations/flutter_modular_annotations.dart';
export 'src/presenter/guards/route_guard.dart';
export 'src/presenter/models/bind.dart';
export 'src/presenter/models/child_route.dart';
export 'src/presenter/models/module_route.dart';
export 'src/presenter/models/wildcard_route.dart';
export 'src/presenter/models/redirect_to_route.dart';
export 'src/presenter/models/modular_args.dart';
export 'src/presenter/models/module.dart';
export 'src/presenter/models/route.dart' hide ParallelRoute;
export 'src/presenter/models/modular_navigator.dart';
export 'src/presenter/widgets/modular_app.dart';
export 'src/presenter/widgets/modular_state.dart';
export 'src/presenter/widgets/navigation_listener.dart';
export 'src/presenter/widgets/widget_module.dart';
export 'src/presenter/navigation/transitions/page_transition.dart';
export 'src/presenter/navigation/transitions/transitions.dart';
export 'package:modular_core/modular_core.dart' show ModularRoute;

/// Instance of Modular for search binds and route.
final Modular = injector<IModularBase>();

@visibleForTesting
String initialRouteDeclaratedInMaterialApp = '/';

extension ModularExtensionMaterial on MaterialApp {
  MaterialApp modular() {
    injector.get<IModularNavigator>().setObserver(navigatorObservers ?? <NavigatorObserver>[]);
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
      routeInformationParser: injector.get<ModularRouteInformationParser>(),
      routerDelegate: injector.get<ModularRouterDelegate>(),
    );

    return app;
  }
}

extension ModularExtensionCupertino on CupertinoApp {
  CupertinoApp modular() {
    injector.get<IModularNavigator>().setObserver(navigatorObservers ?? <NavigatorObserver>[]);
    (injector.get<IModularBase>() as ModularBase).flags.isCupertino = true;
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
      routeInformationParser: injector.get<ModularRouteInformationParser>(),
      routerDelegate: injector.get<ModularRouterDelegate>(),
    );

    return app;
  }
}

/// It acts as a Nested Browser that will be populated by the children of this route.
class RouterOutlet extends StatefulWidget {
  RouterOutlet({Key? key}) : super(key: key);

  @override
  RouterOutletState createState() => RouterOutletState();
}

class RouterOutletState extends State<RouterOutlet> {
  late GlobalKey<NavigatorState> navigatorKey;
  RouterOutletDelegate? delegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    navigatorKey = GlobalKey<NavigatorState>();

    Modular.to.addListener(listener);
  }

  @visibleForTesting
  void listener() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modal = (ModalRoute.of(context)?.settings as ModularPage);
    delegate ??= RouterOutletDelegate(modal.route.uri.toString(), injector.get<ModularRouterDelegate>(), navigatorKey);
    final router = Router.of(context);
    _backButtonDispatcher = router.backButtonDispatcher!.createChildBackButtonDispatcher();
  }

  @override
  void dispose() {
    super.dispose();
    Modular.to.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    _backButtonDispatcher.takePriority();
    return Router(
      routerDelegate: delegate!,
      backButtonDispatcher: _backButtonDispatcher,
    );
  }
}
