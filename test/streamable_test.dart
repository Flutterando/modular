import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal Cubit-like object: synchronous [state], a [stream] of changes, and
/// an async [close]. flutter_modular needs no dependency on the `bloc`
/// package — `addStreamable` takes the stream/close as callbacks.
class CounterCubit {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  int state = 0;
  bool closed = false;

  Stream<int> get stream => _controller.stream;

  void increment() {
    state++;
    _controller.add(state);
  }

  Future<void> close() async {
    closed = true;
    await _controller.close();
  }
}

/// A two-field variant, to prove `Selector` rebuilds only when the SELECTED
/// value changes even though the trigger is a stream.
class MultiCubit {
  final StreamController<void> _controller = StreamController<void>.broadcast();
  int a = 0;
  int b = 0;

  Stream<void> get stream => _controller.stream;

  void incA() {
    a++;
    _controller.add(null);
  }

  void incB() {
    b++;
    _controller.add(null);
  }

  Future<void> close() => _controller.close();
}

CounterCubit? capturedCubit;
int selectorBuilds = 0;

final counterModule = createModule(
  register: (c) {
    c.route(
      '/counter',
      provide: (s) => s.addStreamable<CounterCubit>(
        CounterCubit.new,
        (cubit) => cubit.stream,
        (cubit) => cubit.close(),
      ),
      child: (ctx, state) {
        final cubit = ctx.watch<CounterCubit>();
        capturedCubit = cubit;
        return Scaffold(
          body: Column(
            children: [
              Text('count:${cubit.state}'),
              TextButton(
                onPressed: () => ctx.read<CounterCubit>().increment(),
                child: const Text('inc'),
              ),
            ],
          ),
        );
      },
    );
  },
);

final multiModule = createModule(
  register: (c) {
    c.route(
      '/multi',
      provide: (s) => s.addStreamable<MultiCubit>(
        MultiCubit.new,
        (cubit) => cubit.stream,
        (cubit) => cubit.close(),
      ),
      child: (ctx, state) => Scaffold(
        body: Column(
          children: [
            Selector<MultiCubit, int>(
              selector: (c, cubit) => cubit.a,
              builder: (c, a, _) {
                selectorBuilds++;
                return Text('a:$a');
              },
            ),
            TextButton(
              onPressed: () => ctx.read<MultiCubit>().incA(),
              child: const Text('incA'),
            ),
            TextButton(
              onPressed: () => ctx.read<MultiCubit>().incB(),
              child: const Text('incB'),
            ),
          ],
        ),
      ),
    );
  },
);

void main() {
  setUp(() {
    capturedCubit = null;
    selectorBuilds = 0;
  });

  testWidgets(
    'addStreamable exposes the object itself; watch rebuilds on stream emit',
    (tester) async {
      final boot = bootstrapModule(counterModule);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
            initialRoute: '/counter',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // watch<CounterCubit>() returns the bloc; we read its synchronous state.
      expect(find.text('count:0'), findsOneWidget);

      // read<CounterCubit>() is the same instance (the button increments it).
      await tester.tap(find.text('inc'));
      await tester.pumpAndSettle();

      // The stream emission drove the rebuild, and the fact that the count
      // advanced proves read<CounterCubit>() is the same instance as watch.
      expect(find.text('count:1'), findsOneWidget);
    },
  );

  testWidgets('addStreamable calls the (async) dispose on unmount', (
    tester,
  ) async {
    final boot = bootstrapModule(counterModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          initialRoute: '/counter',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final cubit = capturedCubit!;
    expect(cubit.closed, isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    // close() is async but fire-and-forgotten; `closed` is set synchronously.
    expect(cubit.closed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Selector over a streamable rebuilds only when the selected value changes',
    (tester) async {
      final boot = bootstrapModule(multiModule);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
            initialRoute: '/multi',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('a:0'), findsOneWidget);
      final builds = selectorBuilds;

      // Emitting via incB must NOT rebuild the Selector (it selects `a`).
      await tester.tap(find.text('incB'));
      await tester.pumpAndSettle();
      expect(selectorBuilds, builds);
      expect(find.text('a:0'), findsOneWidget);

      // incA changes the selected value → rebuild.
      await tester.tap(find.text('incA'));
      await tester.pumpAndSettle();
      expect(selectorBuilds, greaterThan(builds));
      expect(find.text('a:1'), findsOneWidget);
    },
  );
}
