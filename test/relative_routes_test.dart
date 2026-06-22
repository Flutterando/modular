import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
// White-box: exercise the pure resolver directly for edge cases.
import 'package:flutter_modular/src/navigation/route_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _btn(String label, VoidCallback onPressed) =>
    TextButton(onPressed: onPressed, child: Text(label));

final module = createModule(
  register: (c) {
    c
      ..route(
        '/home',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('home'),
              _btn(
                'bare',
                () => ctx.pushNamed('dashboard'),
              ), // → /home/dashboard
              _btn('dot', () => ctx.pushNamed('./dashboard')), // same
            ],
          ),
        ),
      )
      ..route(
        '/home/dashboard',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('dashboard'),
              _btn(
                'up',
                () => ctx.pushNamed('../settings'),
              ), // → /home/settings
            ],
          ),
        ),
      )
      ..route(
        '/home/settings',
        child: (ctx, s) => const Scaffold(body: Text('settings')),
      );
  },
);

Future<void> _pump(WidgetTester tester) async {
  final boot = bootstrapModule(module);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: modularRouterConfig(
        boot.routes,
        injector: boot.injector,
        manager: boot.manager,
        initialRoute: '/home',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('resolveRoute (current route treated as a directory)', () {
    test('bare and ./ append UNDER the current route', () {
      expect(
        resolveRoute('dashboard', Uri.parse('/home')).toString(),
        '/home/dashboard',
      );
      expect(
        resolveRoute('./dashboard', Uri.parse('/home')).toString(),
        '/home/dashboard',
      );
    });

    test('.. climbs one level', () {
      expect(
        resolveRoute('..', Uri.parse('/home/dashboard')).toString(),
        '/home/',
      );
      expect(
        resolveRoute('../settings', Uri.parse('/home/dashboard')).toString(),
        '/home/settings',
      );
    });

    test('a leading slash is absolute — current location is ignored', () {
      expect(
        resolveRoute('/products', Uri.parse('/home/dashboard')).toString(),
        '/products',
      );
    });

    test('relative from the root', () {
      expect(
        resolveRoute('dashboard', Uri.parse('/')).toString(),
        '/dashboard',
      );
    });

    test('a query on the reference is preserved', () {
      expect(
        resolveRoute('item?ref=x', Uri.parse('/products')).toString(),
        '/products/item?ref=x',
      );
    });

    test('a trailing slash on the current route is honored as-is', () {
      expect(resolveRoute('a', Uri.parse('/home/')).toString(), '/home/a');
    });
  });

  group('context.pushNamed resolves relative paths', () {
    testWidgets('bare name pushes under the current route', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('bare')); // /home + dashboard
      await tester.pumpAndSettle();
      expect(find.text('dashboard'), findsOneWidget);
    });

    testWidgets('./ behaves like a bare name', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('dot'));
      await tester.pumpAndSettle();
      expect(find.text('dashboard'), findsOneWidget);
    });

    testWidgets('../ climbs to a sibling', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('bare')); // now on /home/dashboard
      await tester.pumpAndSettle();
      await tester.tap(find.text('up')); // ../settings → /home/settings
      await tester.pumpAndSettle();
      expect(find.text('settings'), findsOneWidget);
    });
  });
}
