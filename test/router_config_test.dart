import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingObserver extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => pushes++;
}

void main() {
  testWidgets('routerConfig wires a custom navigatorKey and observers', (
    tester,
  ) async {
    final key = GlobalKey<NavigatorState>();
    final observer = _RecordingObserver();
    final routes = RouteCollection()
      ..add(ModularRoute('/', (context, state) => const Text('home')));

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          routes,
          navigatorKey: key,
          observers: [observer],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(key.currentState, isNotNull); // our key drives the root Navigator
    expect(observer.pushes, greaterThan(0)); // observer saw the initial route
  });

  testWidgets('initialRoute selects the first page when no deep link', (
    tester,
  ) async {
    final routes = RouteCollection()
      ..add(ModularRoute('/', (context, state) => const Text('home')))
      ..add(ModularRoute('/start', (context, state) => const Text('start')));

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(routes, initialRoute: '/start'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('start'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });
}
