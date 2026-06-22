import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class Service {
  String hello() => 'hi';
}

class AuthState {
  bool open = false;
}

void main() {
  test('inject<T>() resolves from the active graph after bootstrap', () {
    final module = createModule(
      register: (c) {
        c.addSingleton<Service>(Service.new);
      },
    );
    bootstrapModule(module);

    expect(inject<Service>(), isA<Service>());
    expect(inject<Service>().hello(), 'hi');
  });

  testWidgets('a guard reads DI through inject<T>() (no exposed injector)', (
    tester,
  ) async {
    final module = createModule(
      register: (c) {
        c
          ..addSingleton<AuthState>(AuthState.new)
          ..route('/', child: (ctx, s) => const Text('home'))
          ..route(
            '/secret',
            guards: [(s) => inject<AuthState>().open ? null : '/'],
            child: (ctx, s) => const Text('secret'),
          );
      },
    );
    final boot = bootstrapModule(module);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          manager: boot.manager,
          initialRoute: '/secret',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Closed → the guard (reading DI via inject) redirected to home.
    expect(find.text('secret'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
