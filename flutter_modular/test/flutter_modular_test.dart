import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MaterialApp extension', () {
    Modular.setInitialRoute('/');
    Modular.setObservers([]);
    Modular.setNavigatorKey(GlobalKey<NavigatorState>());
    final app = MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
    expect(app, isA<MaterialApp>());
  });

  test('CupertinoApp extension', () {
    final app = CupertinoApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
    expect(app, isA<CupertinoApp>());
  });

  testWidgets('RouterOutlet', (tester) async {
    Modular.init(AppModule());
    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    ));

    await tester.pump();
    final finder = find.byKey(keyOutlet);
    expect(finder, findsOneWidget);

    final state = tester.state<RouterOutletState>(find.byKey(keyOutlet));
    state.listener();
  });
}

const keyOutlet = ValueKey('keyOutlet');

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const RouterOutlet(key: keyOutlet));
  }
}
