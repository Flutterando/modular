import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// A plain, non-reactive object with no lifecycle.
class AppConfig {
  final String title = 'Modular';
}

/// A non-reactive object that opts into cleanup by implementing [Disposable].
class DisposableConfig implements Disposable {
  bool disposed = false;

  @override
  void dispose() => disposed = true;
}

AppConfig? capturedConfig;
DisposableConfig? capturedDisposable;

final addModule = createModule(
  register: (c) {
    c.route(
      '/cfg',
      provide: (s) => s
        ..add<AppConfig>(AppConfig.new)
        ..add<DisposableConfig>(DisposableConfig.new),
      child: (ctx, state) {
        capturedConfig = ctx.read<AppConfig>();
        capturedDisposable = ctx.read<DisposableConfig>();
        return Text(
          'cfg:${ctx.watch<AppConfig>().title}',
          textDirection: TextDirection.ltr,
        );
      },
    );
  },
);

final dupModule = createModule(
  register: (c) {
    c.route(
      '/dup',
      provide: (s) => s
        ..add<AppConfig>(AppConfig.new)
        ..add<AppConfig>(AppConfig.new),
      child: (ctx, state) => const SizedBox(),
    );
  },
);

void main() {
  setUp(() {
    capturedConfig = null;
    capturedDisposable = null;
  });

  testWidgets(
    'add() exposes a non-reactive object via read/watch and disposes it on '
    'unmount only when it implements Disposable',
    (tester) async {
      final boot = bootstrapModule(addModule);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
            initialRoute: '/cfg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('cfg:Modular'), findsOneWidget);
      expect(capturedConfig, isNotNull);
      final disposable = capturedDisposable!;
      expect(disposable.disposed, isFalse);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // The Disposable one is cleaned up; the plain AppConfig simply has no
      // dispose to call (and nothing crashes).
      expect(disposable.disposed, isTrue);
    },
  );

  testWidgets('registering the same type twice throws a FlutterError', (
    tester,
  ) async {
    final boot = bootstrapModule(dupModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          initialRoute: '/dup',
        ),
      ),
    );

    // The router builds the page (and runs ScopedHost.initState, where the
    // duplicate-type guard lives) a frame after mount. Pump until it surfaces.
    Object? error;
    for (var i = 0; i < 5 && error == null; i++) {
      await tester.pump();
      error = tester.takeException();
    }

    expect(error, isA<FlutterError>());
  });
}
