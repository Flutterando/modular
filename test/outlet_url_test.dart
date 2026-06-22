import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _btn(String label, VoidCallback onPressed) =>
    TextButton(onPressed: onPressed, child: Text(label));

final outletKey = GlobalKey<RouterOutletState>();

final module = createModule(
  register: (c) {
    c
      ..route(
        '/',
        child: (ctx, s) =>
            Scaffold(body: _btn('toShell', () => ctx.navigate('/shell'))),
      )
      ..route(
        '/shell',
        child: (ctx, s) => Scaffold(body: RouterOutlet(key: outletKey)),
        children: (sub) {
          sub
            ..route('/', child: (ctx, s) => const Text('tabA'))
            ..route('/b', child: (ctx, s) => const Text('tabB'))
            ..route('/b/deep', child: (ctx, s) => const Text('deep'));
        },
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

String? _url(WidgetTester tester) {
  final router =
      tester.widget(find.byWidgetPredicate((w) => w is Router)) as Router;
  return (router.routerDelegate.currentConfiguration as RouteState?)?.uri.path;
}

void main() {
  testWidgets('a RouterOutlet tab switch shows in the URL; a push does not', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('toShell')); // navigate('/shell')
    await tester.pumpAndSettle();
    expect(find.text('tabA'), findsOneWidget);
    expect(_url(tester), '/shell'); // the shell base

    // Tab switch via the outlet → the URL now carries the sub-route.
    outletKey.currentState!.navigate('/shell/b');
    await tester.pumpAndSettle();
    expect(find.text('tabB'), findsOneWidget);
    expect(_url(tester), '/shell/b');

    // A push INSIDE the outlet stays OUT of the URL (tab base unchanged).
    unawaited(outletKey.currentState!.push('/shell/b/deep'));
    await tester.pumpAndSettle();
    expect(find.text('deep'), findsOneWidget);
    expect(_url(tester), '/shell/b');

    // Pop back within the outlet → still the tab base.
    outletKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('tabB'), findsOneWidget);
    expect(_url(tester), '/shell/b');
  });
}
