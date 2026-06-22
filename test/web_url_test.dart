import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

// Web routing rules:
//  1. The URL mirrors the stack BASE (`navigate`/deep link own it); `pushNamed`
//     layers pages that stay OUT of the URL (modal-like, lost on refresh).
//  2. A deep link / refresh boots straight to its route — the platform's real
//     entry URL is honored, not collapsed to the root.

Widget _btn(String label, VoidCallback onPressed) =>
    TextButton(onPressed: onPressed, child: Text(label));

final module = createModule(
  register: (c) {
    c
      ..route(
        '/',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('home'),
              _btn('push', () => ctx.pushNamed('/detail')),
              _btn('navSettings', () => ctx.navigate('/settings')),
            ],
          ),
        ),
      )
      ..route(
        '/detail',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('detail'),
              _btn('back', () => ctx.maybePop()),
            ],
          ),
        ),
      )
      ..route(
        '/settings',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('settings'),
              _btn('pushFromSettings', () => ctx.pushNamed('/detail')),
            ],
          ),
        ),
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
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// What the browser address bar would show — read straight off the delegate's
/// reported configuration (the source of truth for the URL).
String? _url(WidgetTester tester) {
  final router =
      tester.widget(find.byWidgetPredicate((w) => w is Router)) as Router;
  return (router.routerDelegate.currentConfiguration as RouteState?)?.uri.path;
}

void main() {
  testWidgets(
    'URL mirrors the base: push stays out, navigate sets it, pop keeps it',
    (tester) async {
      await _pump(tester);
      expect(_url(tester), '/');

      // push: the detail page shows, but the URL does NOT move off the base.
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      expect(_url(tester), '/');

      // navigate: resets the stack AND owns the URL.
      await tester.tap(find.text('back')); // back to home first
      await tester.pumpAndSettle();
      await tester.tap(find.text('navSettings'));
      await tester.pumpAndSettle();
      expect(find.text('settings'), findsOneWidget);
      expect(find.text('home'), findsNothing); // stack was reset
      expect(_url(tester), '/settings');

      // push on top of the NEW base: still hidden from the URL.
      await tester.tap(find.text('pushFromSettings'));
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      expect(_url(tester), '/settings');

      // pop back down to the base: the URL never moved.
      await tester.tap(find.text('back'));
      await tester.pumpAndSettle();
      expect(find.text('settings'), findsOneWidget);
      expect(_url(tester), '/settings');
    },
  );

  testWidgets('a deep link boots straight to that route (not the root)', (
    tester,
  ) async {
    // The platform hands us the real entry URL via defaultRouteName.
    tester.platformDispatcher.defaultRouteNameTestValue = '/settings';
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

    await _pump(tester);

    expect(find.text('settings'), findsOneWidget);
    expect(find.text('home'), findsNothing); // did NOT fall back to '/'
    expect(_url(tester), '/settings');
  });
}
