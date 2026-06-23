import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class MultiVM extends ChangeNotifier {
  int a = 0;
  int b = 0;
  void incA() {
    a++;
    notifyListeners();
  }

  void incB() {
    b++;
    notifyListeners();
  }
}

int selectBuilds = 0;

final sModule = createModule(
  register: (c) {
    c.route(
      '/',
      provide: (s) => s.addChangeNotifier<MultiVM>(MultiVM.new),
      child: (ctx, state) => Scaffold(
        body: Column(
          children: [
            Builder(
              builder: (c) {
                final a = c.select<MultiVM, int>((vm) => vm.a);
                selectBuilds++;
                return Text('a:$a');
              },
            ),
            TextButton(
              onPressed: () => ctx.read<MultiVM>().incA(),
              child: const Text('incA'),
            ),
            TextButton(
              onPressed: () => ctx.read<MultiVM>().incB(),
              child: const Text('incB'),
            ),
          ],
        ),
      ),
    );
  },
);

Widget _boot() {
  final boot = bootstrapModule(sModule);
  return MaterialApp.router(
    routerConfig: modularRouterConfig(boot.routes, injector: boot.injector),
  );
}

void main() {
  testWidgets('context.select rebuilds only when the selected value changes', (
    tester,
  ) async {
    selectBuilds = 0;
    await tester.pumpWidget(_boot());
    await tester.pumpAndSettle();
    expect(find.text('a:0'), findsOneWidget);
    final builds = selectBuilds;

    // Changing `b` must NOT rebuild the selecting widget (it selects `a`).
    await tester.tap(find.text('incB'));
    await tester.pumpAndSettle();
    expect(selectBuilds, builds);
    expect(find.text('a:0'), findsOneWidget);

    // Changing `a` rebuilds it, and the new selected value is delivered.
    await tester.tap(find.text('incA'));
    await tester.pumpAndSettle();
    expect(selectBuilds, greaterThan(builds));
    expect(find.text('a:1'), findsOneWidget);
  });

  testWidgets('context.select keeps tracking across rebuilds', (tester) async {
    selectBuilds = 0;
    await tester.pumpWidget(_boot());
    await tester.pumpAndSettle();

    // Two consecutive selected changes both land (selectors are refreshed each
    // build, never accumulated or dropped).
    await tester.tap(find.text('incA'));
    await tester.pumpAndSettle();
    expect(find.text('a:1'), findsOneWidget);

    final builds = selectBuilds;
    await tester.tap(find.text('incA'));
    await tester.pumpAndSettle();
    expect(find.text('a:2'), findsOneWidget);
    expect(selectBuilds, greaterThan(builds));

    // An unrelated change still does not rebuild after several rebuilds.
    final settled = selectBuilds;
    await tester.tap(find.text('incB'));
    await tester.pumpAndSettle();
    expect(selectBuilds, settled);
  });

  testWidgets('context.select throws when no scoped T is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            c.select<MultiVM, int>((vm) => vm.a);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(tester.takeException(), isA<FlutterError>());
  });
}
