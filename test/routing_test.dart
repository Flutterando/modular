import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('extracts path params (/product/:id)', (tester) async {
    final routes = RouteCollection()
      ..add(
        ModularRoute(
          '/product/:id',
          (context, state) => Text('product ${state['id']}'),
        ),
      );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(routes, initialRoute: '/product/42'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('product 42'), findsOneWidget);
  });

  testWidgets('push grows the stack and pop returns', (tester) async {
    final routes = RouteCollection()
      ..add(
        ModularRoute(
          '/',
          (context, state) => Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => ctx.pushNamed('/details'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      )
      ..add(
        ModularRoute(
          '/details',
          (context, state) => Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('back'),
              ),
            ),
          ),
        ),
      );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(routes)),
    );
    await tester.pumpAndSettle();
    expect(find.text('go'), findsOneWidget);

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('back'), findsOneWidget);

    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();
    expect(find.text('go'), findsOneWidget);
    expect(find.text('back'), findsNothing);
  });
}
