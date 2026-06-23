import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// An object whose reactivity lives on a [Listenable] *property* (a
/// `ValueNotifier`), not on the object itself — the case `addListenable`
/// exists for. `watch<Holder>()` returns the holder; rebuilds are driven by
/// `holder.counter`.
class Holder {
  final ValueNotifier<int> counter = ValueNotifier<int>(0);
  bool disposed = false;

  void increment() => counter.value++;

  void dispose() {
    disposed = true;
    counter.dispose();
  }
}

Holder? captured;

final holderModule = createModule(
  register: (c) {
    c.route(
      '/holder',
      provide: (s) => s.addListenable<Holder>(
        Holder.new,
        (holder) => holder.counter,
        (holder) => holder.dispose(),
      ),
      child: (ctx, state) {
        final holder = ctx.watch<Holder>();
        captured = holder;
        return Scaffold(
          body: Column(
            children: [
              Text('v:${holder.counter.value}'),
              TextButton(
                onPressed: () => ctx.read<Holder>().increment(),
                child: const Text('inc'),
              ),
            ],
          ),
        );
      },
    );
  },
);

void main() {
  setUp(() => captured = null);

  testWidgets(
    'addListenable exposes the object; watch rebuilds when its Listenable '
    'property notifies; dispose is called on unmount',
    (tester) async {
      final boot = bootstrapModule(holderModule);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
            initialRoute: '/holder',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('v:0'), findsOneWidget);

      await tester.tap(find.text('inc'));
      await tester.pumpAndSettle();
      expect(find.text('v:1'), findsOneWidget);

      final holder = captured!;
      expect(holder.disposed, isFalse);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(holder.disposed, isTrue);
    },
  );
}
