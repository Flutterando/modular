import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// Feature-level repositories, bound only while their feature is active.
class CatalogRepo {}

class SearchRepo implements Disposable {
  static int disposed = 0;
  @override
  void dispose() => disposed++;
}

final catalogModule = createModule(
  path: '/catalog',
  register: (c) => c
    ..addSingleton<CatalogRepo>(CatalogRepo.new)
    ..route(
      '/',
      child: (ctx, s) {
        inject<CatalogRepo>();
        return Column(
          children: [
            const Text('catalog'),
            TextButton(
              onPressed: () => ctx.navigate('/search/'),
              child: const Text('go-search'),
            ),
            TextButton(
              onPressed: () => ctx.pushNamed('/search/'),
              child: const Text('push-search'),
            ),
          ],
        );
      },
    ),
);

final searchModule = createModule(
  path: '/search',
  register: (c) => c
    ..addSingleton<SearchRepo>(SearchRepo.new)
    ..route(
      '/',
      child: (ctx, s) {
        inject<SearchRepo>();
        return TextButton(
          onPressed: () => ctx.navigate('/catalog/'),
          child: const Text('search'),
        );
      },
    ),
);

/// A shell at `/` whose body is a RouterOutlet hosting the feature modules.
final shellModule = createModule(
  register: (c) => c.route(
    '/',
    child: (ctx, s) => const Scaffold(body: RouterOutlet()),
    children: (sub) => sub
      ..module(catalogModule)
      ..module(searchModule),
  ),
);

Future<void> _boot(WidgetTester tester) async {
  final boot = bootstrapModule(shellModule);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: modularRouterConfig(
        boot.routes,
        injector: boot.injector,
        manager: boot.manager,
        initialRoute: '/catalog/',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('navigate inside an outlet activates the target feature binds', (
    tester,
  ) async {
    SearchRepo.disposed = 0;
    await _boot(tester);
    expect(find.text('catalog'), findsOneWidget);

    await tester.tap(find.text('go-search'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('search'), findsOneWidget);

    // Leaving the feature releases its binds.
    await tester.tap(find.text('search'));
    await tester.pumpAndSettle();
    expect(find.text('catalog'), findsOneWidget);
    expect(SearchRepo.disposed, 1);
  });

  testWidgets('pushNamed inside an outlet activates the target feature binds', (
    tester,
  ) async {
    await _boot(tester);
    await tester.tap(find.text('push-search'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('search'), findsOneWidget);
  });
}
