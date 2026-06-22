import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _btn(String label, VoidCallback onPressed) =>
    TextButton(onPressed: onPressed, child: Text(label));

String? aResult; // result delivered back to the awaiter of `pushNamed('/a')`

final module = createModule(
  register: (c) {
    c
      ..route(
        '/',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('home'),
              _btn(
                'toA',
                () async => aResult = await ctx.pushNamed<String>('/a'),
              ),
              _btn('tryPop', () => ctx.maybePop()),
            ],
          ),
        ),
      )
      ..route(
        '/a',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('A'),
              _btn('toB', () => ctx.pushNamed('/b')),
              _btn('replaceX', () => ctx.replace('/x')),
              _btn('navX', () => ctx.navigate('/x')),
              _btn(
                'popPushX',
                () => ctx.popAndPushNamed('/x', result: 'fromA'),
              ),
            ],
          ),
        ),
      )
      ..route(
        '/b',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [
              const Text('B'),
              _btn('popHome', () => ctx.popUntil((st) => st.uri.path == '/')),
              _btn(
                'pushXClear',
                () => ctx.pushNamedAndRemoveUntil(
                  '/x',
                  (st) => st.uri.path == '/',
                ),
              ),
            ],
          ),
        ),
      )
      ..route(
        '/x',
        child: (ctx, s) => Scaffold(
          body: Column(
            children: [const Text('X'), _btn('back', () => ctx.maybePop())],
          ),
        ),
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

void main() {
  testWidgets('replace swaps the top route (back skips the replaced one)', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('toA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('replaceX')); // [/, /a] → [/, /x]
    await tester.pumpAndSettle();
    expect(find.text('X'), findsOneWidget);

    await tester.tap(find.text('back')); // pop X → home, NOT A
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('popUntil pops back to the matching route', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('toA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('toB')); // [/, /a, /b]
    await tester.pumpAndSettle();

    await tester.tap(find.text('popHome'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsNothing);
  });

  testWidgets('navigate resets the WHOLE stack (even home is gone)', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('toA')); // [/, /a]
    await tester.pumpAndSettle();

    await tester.tap(find.text('navX')); // → [/x]
    await tester.pumpAndSettle();
    expect(find.text('X'), findsOneWidget);
    expect(find.text('home'), findsNothing); // stack was reset, not pushed
    expect(find.text('A'), findsNothing);
  });

  testWidgets('maybePop is a no-op at the stack base', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('tryPop')); // nothing to pop
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget); // still here, no crash
  });

  testWidgets('popAndPushNamed pops with a result, then pushes', (
    tester,
  ) async {
    aResult = null;
    await _pump(tester);
    await tester.tap(find.text('toA')); // [/, /a], home awaits the result
    await tester.pumpAndSettle();

    await tester.tap(find.text('popPushX')); // pop /a (→ 'fromA'), push /x
    await tester.pumpAndSettle();
    expect(find.text('X'), findsOneWidget);
    expect(aResult, 'fromA'); // the popped /a delivered its result

    await tester.tap(find.text('back')); // pop X → home (A was replaced)
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('pushNamedAndRemoveUntil clears down to the predicate', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('toA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('toB')); // [/, /a, /b]
    await tester.pumpAndSettle();

    await tester.tap(find.text('pushXClear')); // push /x, remove until '/'
    await tester.pumpAndSettle();
    expect(find.text('X'), findsOneWidget); // → [/, /x]

    await tester.tap(find.text('back')); // pop X → home
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsNothing);
  });
}
