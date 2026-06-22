import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app_module.dart';
import 'core/state/theme_controller.dart';

/// Entry point. [ModularApp] bootstraps [appModule] once, owns the injector,
/// builds the router config, and hosts APP-SCOPED state via `provide` —
/// anchored ABOVE the `MaterialApp`, so the [ThemeController] can drive the app
/// theme (something a page-scoped VM, below the `Navigator`, cannot do).
void main() {
  // Use real paths on the web (`/products/1`) instead of the default hash
  // fragment (`/#/products/1`), so URLs are clean and deep-linkable. This sets
  // the `PathUrlStrategy`; it's a no-op off the web.
  usePathUrlStrategy();
  runApp(
    ModularApp(
      module: appModule,
      // The landing feature is mounted at `/home`, so that's the initial route
      // (the bare `/` has no page). A real entry URL still overrides it.
      initialRoute: '/home',
      provide: (s) => s.addChangeNotifier<ThemeController>(ThemeController.new),
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>(); // above the MaterialApp
    return MaterialApp.router(
      title: 'flutter_modular v7 example',
      themeMode: theme.mode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: ModularApp.routerConfigOf(context),
    );
  }
}
