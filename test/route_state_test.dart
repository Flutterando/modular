import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

final outletKey = GlobalKey<RouterOutletState>();

/// A flat route with a `:id` param — proves `routeState()` RESOLVES path params
/// (the stored stack entry doesn't carry them; they're merged at render).
final paramsModule = createModule(
  register: (c) {
    c
      ..route(
        '/',
        child: (ctx, s) => Scaffold(
          body: TextButton(
            onPressed: () => ctx.navigate('/users/42'),
            child: const Text('go'),
          ),
        ),
      )
      ..route(
        '/users/:id',
        // Reads the param via routeState(), not the builder's `s`.
        child: (ctx, s) {
          final id = ctx.routeState().params['id'];
          return Text('user $id');
        },
      );
  },
);

/// A shell whose body is a [RouterOutlet] and whose SIBLING reads the current
/// location via `routeState()` — the exact shape of a bottom bar that must
/// reflect the active tab without being able to reach the outlet via `context`.
final shellModule = createModule(
  register: (c) {
    c.route(
      '/shell',
      child: (ctx, s) => Column(
        children: [
          Expanded(child: RouterOutlet(key: outletKey)),
          Builder(builder: (ctx) => Text('loc:${ctx.routeState().uri.path}')),
        ],
      ),
      children: (sub) {
        sub
          ..route('/', child: (ctx, s) => const Text('A'))
          ..route('/b', child: (ctx, s) => const Text('B'));
      },
    );
  },
);

Future<void> _pump(WidgetTester tester, Module module) async {
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

void main() {
  testWidgets('routeState().params resolves the matched path params', (
    tester,
  ) async {
    await _pump(tester, paramsModule);

    await tester.tap(find.text('go')); // navigate('/users/42')
    await tester.pumpAndSettle();

    // The param is reached through routeState(), not the builder arg.
    expect(find.text('user 42'), findsOneWidget);
  });

  testWidgets(
    'routeState() reactively reflects the active outlet sub-route to a '
    'SIBLING of the outlet (the active-tab-highlight mechanism)',
    (tester) async {
      tester.platformDispatcher.defaultRouteNameTestValue = '/shell';
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
      await _pump(tester, shellModule);

      expect(find.text('A'), findsOneWidget);
      expect(find.text('loc:/shell'), findsOneWidget); // sibling sees the base

      // Tab switch via the outlet → the SIBLING (which can't reach the
      // outlet via context) re-derives the location reactively, no local state.
      outletKey.currentState!.navigate('/shell/b');
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(find.text('loc:/shell/b'), findsOneWidget);
    },
  );

  testWidgets('routeState() exposes the deep-linked outlet sub-route on boot', (
    tester,
  ) async {
    // Boot straight into a non-default tab — the sibling must read THAT, not
    // the shell base (the bug the highlight fix closes).
    tester.platformDispatcher.defaultRouteNameTestValue = '/shell/b';
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    await _pump(tester, shellModule);

    expect(find.text('B'), findsOneWidget);
    expect(find.text('loc:/shell/b'), findsOneWidget);
  });
}
