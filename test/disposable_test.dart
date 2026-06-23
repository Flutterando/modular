import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// A NON-reactive resource: lifecycle only, no `ChangeNotifier`.
class Connection implements Disposable {
  bool closed = false;

  @override
  void dispose() => closed = true;
}

/// A reactive VM that DEPENDS on the non-reactive resource — injected from the
/// same page-local scope, so it gets the page's single [Connection] instance.
class FeedVM extends ChangeNotifier {
  FeedVM(this.connection);
  final Connection connection;
}

Connection? captured;

final feedModule = createModule(
  register: (c) {
    c.route(
      '/feed',
      provide: (s) => s
        ..add<Connection>(Connection.new)
        ..addChangeNotifier<FeedVM>(FeedVM.new),
      child: (ctx, state) {
        captured = ctx.watch<FeedVM>().connection;
        return const Scaffold(body: Text('feed'));
      },
    );
  },
);

void main() {
  setUp(() => captured = null);

  testWidgets(
    'page-scoped add() instance is the same the VM injects (per-page '
    'singleton) and is disposed on unmount because it implements Disposable',
    (tester) async {
      final boot = bootstrapModule(feedModule);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
            initialRoute: '/feed',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final connection = captured!;
      expect(connection.closed, isFalse);

      // Unmount the page. The Connection — registered via add(), non-reactive
      // — is cleaned up because it implements Disposable. Because the
      // VM-injected instance is the one that closes, this also proves the
      // per-page singleton sharing.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(connection.closed, isTrue);
    },
  );
}
