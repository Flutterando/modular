import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the matched route through Navigator 2.0', (
    tester,
  ) async {
    final routes = RouteCollection()
      ..add(ModularRoute('/', (context, state) => const Text('home')));

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(routes)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('shows not-found for an unmatched path', (tester) async {
    final routes = RouteCollection()
      ..add(ModularRoute('/', (context, state) => const Text('home')));

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(routes, initialRoute: '/missing'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Route not found'), findsOneWidget);
  });
}
