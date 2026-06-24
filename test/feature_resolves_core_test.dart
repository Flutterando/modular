import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// A shared (root-owned) dependency, registered in a path-less "core" module.
class ApiConfig {
  ApiConfig(this.baseUrl);
  final String baseUrl;
}

/// A FEATURE module-level service whose constructor needs the core [ApiConfig].
/// Before 7.1.0 this could not resolve — a feature's binds ran in a leaf
/// injector blind to root-owned binds. With `auto_injector >= 2.2.0` and
/// `_bind`'s `resolveUpward`, it resolves the core dep.
class FeatureService {
  FeatureService(this.config);
  final ApiConfig config;
}

final coreModule = createModule(
  register: (c) => c.addInstance<ApiConfig>(ApiConfig('https://api.example')),
);

String? resolvedBaseUrl;

final featureModule = createModule(
  path: '/feature',
  register: (c) => c
    // MODULE-LEVEL bind (eager singleton), depends on the core ApiConfig.
    ..addSingleton<FeatureService>(FeatureService.new)
    ..route('/', child: (ctx, s) {
      resolvedBaseUrl = inject<FeatureService>().config.baseUrl;
      return const Scaffold(body: Text('feature'));
    }),
);

final rootModule = createModule(
  register: (c) => c
    ..route('/', child: (ctx, s) => Scaffold(
          body: TextButton(
            onPressed: () => ctx.pushNamed('/feature'),
            child: const Text('open'),
          ),
        ))
    ..module(coreModule)
    ..module(featureModule),
);

void main() {
  testWidgets(
    'a feature module-level bind resolves a root-owned (core) dependency',
    (tester) async {
      resolvedBaseUrl = null;
      final boot = bootstrapModule(rootModule);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          manager: boot.manager,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('feature'), findsOneWidget);
      expect(resolvedBaseUrl, 'https://api.example');
    },
  );
}
