import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// A MANUAL shell (the case `RouterOutlet` is for): a page whose body is a
/// `RouterOutlet` rendering its children. Its index child is the sole/seed
/// entry of the nested Navigator, so the automatic AppBar arrow can't see the
/// root stack below — that is where `context.canPop()` is needed.
final shellModule = createModule(
  register: (c) {
    c
      ..route(
        '/',
        child: (ctx, s) => Scaffold(
          body: TextButton(
            onPressed: () => ctx.pushNamed('/shell'),
            child: const Text('go'),
          ),
        ),
      )
      ..route(
        '/shell',
        child: (ctx, s) => const Scaffold(body: RouterOutlet()),
        children: (sub) {
          sub.route(
            '/',
            child: (ctx, s) => Scaffold(
              appBar: AppBar(
                leading: ctx.canPop()
                    ? BackButton(onPressed: () => ctx.pop())
                    : null,
                title: const Text('inner'),
              ),
            ),
          );
        },
      );
  },
);

void main() {
  testWidgets(
    'canPop() bubbles to the root from a shell index (outlet seed), so an '
    'explicit back button shows and returns home',
    (tester) async {
      final boot = bootstrapModule(shellModule);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      // Inner index: its outlet Navigator has one page, but canPop() sees the
      // root stack → the explicit BackButton is shown.
      expect(find.text('inner'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget); // bubbled pop returned home
    },
  );
}
