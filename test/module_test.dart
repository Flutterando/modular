import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class Counter {
  int value = 0;
}

final adminModule = createModule(
  path: '/admin',
  register: (c) {
    c.route('/', child: (context, state) => const Text('admin home'));
  },
);

final appModule = createModule(
  register: (c) {
    c
      ..addSingleton<Counter>(Counter.new)
      ..route('/', child: (context, state) => const Text('home'))
      ..route(
        '/product/:id',
        child: (context, state) => Text('product ${state['id']}'),
      )
      ..module(adminModule); // admin declares path '/admin'
  },
);

void main() {
  test('module declares routes (params + mounted submodule) and binds', () {
    final boot = bootstrapModule(appModule);

    expect(boot.routes.match(Uri.parse('/'))?.last.route.path, '/');
    expect(
      boot.routes.match(Uri.parse('/product/42'))?.last.params['id'],
      '42',
    );

    // A mounted module is a NAMESPACE: its '/' index is flattened to '/admin'
    // (no outlet shell), so the chain is a single level.
    final admin = boot.routes.match(Uri.parse('/admin'));
    expect(admin?.length, 1);
    expect(admin?.last.route.path, '/admin');

    expect(boot.injector.get<Counter>(), isA<Counter>());
  });

  test('a module path must start with "/" and carry no dynamic segment', () {
    expect(
      () => createModule(path: '/checkout', register: (_) {}),
      returnsNormally,
    );
    expect(() => createModule(register: (_) {}), returnsNormally); // no path ok
    expect(
      () => createModule(path: 'checkout', register: (_) {}),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => createModule(path: '/users/:id', register: (_) {}),
      throwsA(isA<AssertionError>()),
    );
  });

  testWidgets('renders a route declared by a mounted module', (tester) async {
    final boot = bootstrapModule(appModule);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(boot.routes, initialRoute: '/admin'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('admin home'), findsOneWidget);
  });
}
