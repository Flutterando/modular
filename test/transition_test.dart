import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

final tModule = createModule(
  register: (c) {
    c.route(
      '/',
      transition: TransitionType.fade,
      child: (ctx, s) => const Text('faded'),
    );
  },
);

void main() {
  testWidgets('a route renders with a custom (fade) transition', (
    tester,
  ) async {
    final boot = bootstrapModule(tModule);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(boot.routes)),
    );
    await tester.pumpAndSettle();

    // The fade page route builds and settles to the content.
    expect(find.text('faded'), findsOneWidget);
    expect(find.byType(FadeTransition), findsWidgets);
  });
}
