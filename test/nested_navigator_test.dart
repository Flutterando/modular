import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

int shellInits = 0;

class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  @override
  void initState() {
    super.initState();
    shellInits++;
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Column(
      children: [
        Text('shell'),
        Expanded(child: RouterOutlet()),
      ],
    ),
  );
}

final nestedModule = createModule(
  register: (c) {
    c.route(
      '/shell',
      child: (ctx, s) => const _Shell(),
      children: (sub) {
        sub
          ..route(
            '/a',
            child: (ctx, s) => Column(
              children: [
                const Text('A'),
                TextButton(
                  onPressed: () => ctx.pushNamed('/shell/b'),
                  child: const Text('toB'),
                ),
              ],
            ),
          )
          ..route(
            '/b',
            child: (ctx, s) => Column(
              children: [
                const Text('B'),
                TextButton(
                  onPressed: () => ctx.pop(),
                  child: const Text('popB'),
                ),
              ],
            ),
          );
      },
    );
  },
);

void main() {
  testWidgets('outlet has its own push/pop sub-stack; the shell persists', (
    tester,
  ) async {
    shellInits = 0;
    final boot = bootstrapModule(nestedModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          initialRoute: '/shell/a',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('shell'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(shellInits, 1);

    // Push within the outlet → B on top of A, shell NOT recreated.
    await tester.tap(find.text('toB'));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
    expect(find.text('shell'), findsOneWidget);
    expect(shellInits, 1); // shell persisted → it was an outlet sub-stack push

    // Pop the outlet → back to A.
    await tester.tap(find.text('popB'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    expect(shellInits, 1);
  });
}
