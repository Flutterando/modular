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

int selectorBuilds = 0;

final gModule = createModule(
  register: (c) {
    c.route(
      '/',
      provide: (s) => s.addChangeNotifier<MultiVM>(MultiVM.new),
      child: (ctx, state) => Scaffold(
        body: Column(
          children: [
            Selector<MultiVM, int>(
              selector: (c, vm) => vm.a,
              builder: (c, a, _) {
                selectorBuilds++;
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

void main() {
  testWidgets('Selector rebuilds only when the selected value changes', (
    tester,
  ) async {
    selectorBuilds = 0;
    final boot = bootstrapModule(gModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(boot.routes, injector: boot.injector),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('a:0'), findsOneWidget);
    final builds = selectorBuilds;

    // Changing `b` must NOT rebuild the Selector (it selects `a`).
    await tester.tap(find.text('incB'));
    await tester.pumpAndSettle();
    expect(selectorBuilds, builds);
    expect(find.text('a:0'), findsOneWidget);

    // Changing `a` rebuilds it.
    await tester.tap(find.text('incA'));
    await tester.pumpAndSettle();
    expect(selectorBuilds, greaterThan(builds));
    expect(find.text('a:1'), findsOneWidget);
  });
}
