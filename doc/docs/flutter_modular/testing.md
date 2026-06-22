---
sidebar_position: 7
---

# Testing

Because a module is just data — routes + DI — you can bootstrap one in a test and assert
on it directly, with no widgets. For UI you mount the router config in a `MaterialApp`
and pump as usual. The patterns below mirror **flutter_modular**'s own test suite.

## Bootstrapping a module

`bootstrapModule(module)` walks the module tree and returns a `ModularBootstrap` with
the matched `routes`, the `injector`, and the lifecycle `manager`:

```dart
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class Counter {
  int value = 0;
}

final adminModule = createModule(
  path: '/admin',
  register: (c) => c.route('/', child: (ctx, state) => const Text('admin home')),
);

final appModule = createModule(
  register: (c) {
    c
      ..addSingleton<Counter>(Counter.new)
      ..route('/', child: (ctx, state) => const Text('home'))
      ..route('/product/:id', child: (ctx, state) => Text('product ${state['id']}'))
      ..module(adminModule);
  },
);

void main() {
  test('routes (params + mounted submodule) and binds', () {
    final boot = bootstrapModule(appModule);

    // Match a Uri to a chain of routes (root → leaf) with captured params.
    expect(boot.routes.match(Uri.parse('/'))?.last.route.path, '/');
    expect(boot.routes.match(Uri.parse('/product/42'))?.last.params['id'], '42');

    // A mounted module is a namespace: '/admin' is a single, flattened level.
    final admin = boot.routes.match(Uri.parse('/admin'));
    expect(admin?.length, 1);
    expect(admin?.last.route.path, '/admin');

    // Binds resolve from the graph.
    expect(boot.injector.get<Counter>(), isA<Counter>());
  });
}
```

### Asserting mount‑path rules

A module's `path` must be a static prefix — a good thing to lock down in a test:

```dart
expect(() => createModule(path: '/checkout', register: (_) {}), returnsNormally);
expect(() => createModule(register: (_) {}), returnsNormally);            // no path ok
expect(() => createModule(path: 'checkout', register: (_) {}),
    throwsA(isA<AssertionError>()));                                       // must start with '/'
expect(() => createModule(path: '/users/:id', register: (_) {}),
    throwsA(isA<AssertionError>()));                                       // no ':param'
```

## Resolving dependencies

After `bootstrapModule`, `inject<T>()` resolves from the active graph — handy for testing
services and the values guards see:

```dart
test('inject<T>() resolves from the active graph after bootstrap', () {
  final module = createModule(register: (c) => c.addSingleton<Service>(Service.new));
  bootstrapModule(module);

  expect(inject<Service>(), isA<Service>());
  expect(inject<Service>().hello(), 'hi');
});
```

## Testing routes in a widget

Mount the bootstrapped `routes` through `modularRouterConfig` inside a
`MaterialApp.router`, then pump. Pass `injector`/`manager` when the routes resolve binds
or provide page‑scoped state:

```dart
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
```

## Testing guards

A [guard](./navigation.md#guards) redirects before its page is shown — assert the
destination renders instead:

```dart
testWidgets('a guard redirects before the page is shown', (tester) async {
  final boot = bootstrapModule(guardedModule);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: modularRouterConfig(boot.routes, initialRoute: '/admin'),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('login'), findsOneWidget); // guard sent us here
  expect(find.text('admin'), findsNothing);
});
```

## Testing page‑scoped state

A page‑scoped view model is built with its module dependencies at mount and disposed on
unmount. You can assert both — `watch` rebuilds on `notifyListeners`, and unmounting the
tree triggers `dispose()`:

```dart
testWidgets('builds the VM with deps, rebuilds on notify, disposes on unmount',
    (tester) async {
  final boot = bootstrapModule(pModule);

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: modularRouterConfig(
        boot.routes,
        injector: boot.injector,
        initialRoute: '/product',
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('load'));     // calls vm.load() via context.read
  await tester.pumpAndSettle();
  expect(find.text('Widget X'), findsOneWidget); // dep resolved + watch rebuilt

  await tester.pumpWidget(const SizedBox()); // unmount → VM.dispose() runs
  await tester.pumpAndSettle();
});
```

:::tip
See the [`test/`](https://github.com/Flutterando/modular/tree/master/test) directory in
the repository for the full suite — routing, guards, `provide`/dispose, outlets,
relative routes, arguments, transitions and web URLs.
:::
