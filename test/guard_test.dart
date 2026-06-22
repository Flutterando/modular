import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

String? authGuard(RouteState state) =>
    '/login'; // always redirect, for the test

final guardedModule = createModule(
  register: (c) {
    c
      ..route('/', child: (ctx, s) => const Text('home'))
      ..route(
        '/admin',
        guards: [authGuard],
        child: (ctx, s) => const Text('admin'),
      )
      ..route('/login', child: (ctx, s) => const Text('login'));
  },
);

void main() {
  testWidgets('a guard redirects before the page is shown', (tester) async {
    final boot = bootstrapModule(guardedModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(boot.routes, initialRoute: '/admin'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
    expect(find.text('admin'), findsNothing);
  });

  testWidgets('unguarded route is shown normally', (tester) async {
    final boot = bootstrapModule(guardedModule);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(boot.routes)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
