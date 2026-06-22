import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

int created = 0;
int disposed = 0;

/// A feature module's OWN bind. Created when the module's first route enters,
/// disposed only when its LAST route leaves.
class CatalogService implements Disposable {
  CatalogService() {
    created++;
  }

  @override
  void dispose() => disposed++;
}

/// The feature module: a singleton + two routes that both belong to it.
final catalogModule = createModule(
  path: '/catalog',
  register: (c) {
    c
      ..addSingleton<CatalogService>(CatalogService.new)
      ..route(
        '/',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('catalog'),
              TextButton(
                onPressed: () => ctx.pushNamed('/catalog/item'),
                child: const Text('toItem'),
              ),
              TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('toHome'),
              ),
            ],
          ),
        ),
      )
      ..route(
        '/item',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('item'),
              TextButton(onPressed: () => ctx.pop(), child: const Text('back')),
            ],
          ),
        ),
      );
  },
);

final rootModule = createModule(
  register: (c) {
    c
      ..route(
        '/',
        child: (ctx, s) => Scaffold(
          body: TextButton(
            onPressed: () => ctx.pushNamed('/catalog'),
            child: const Text('open'),
          ),
        ),
      )
      ..module(catalogModule);
  },
);

void main() {
  setUp(() {
    created = 0;
    disposed = 0;
  });

  testWidgets(
    'feature binds: bound on first route, disposed only after the LAST '
    'route leaves, recreated on re-entry',
    (tester) async {
      final boot = bootstrapModule(rootModule);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
            manager: boot.manager,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Home: the catalog module has not been entered → not bound.
      expect(created, 0);
      expect(disposed, 0);

      // Enter route A (/catalog) → module bound, service created once.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('catalog'), findsOneWidget);
      expect(created, 1);
      expect(disposed, 0);

      // Push route B (/catalog/item) → SAME module still active, no rebuild.
      await tester.tap(find.text('toItem'));
      await tester.pumpAndSettle();
      expect(find.text('item'), findsOneWidget);
      expect(created, 1);
      expect(disposed, 0);

      // Pop B → A is still active → NOT disposed.
      await tester.tap(find.text('back'));
      await tester.pumpAndSettle();
      expect(find.text('catalog'), findsOneWidget);
      expect(disposed, 0);

      // Pop A (last route of the module) → NOW disposed.
      await tester.tap(find.text('toHome'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(disposed, 1);

      // Re-enter → a fresh instance is created.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(created, 2);
      expect(disposed, 1);
    },
  );
}
