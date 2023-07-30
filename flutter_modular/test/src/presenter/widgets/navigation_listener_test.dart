import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NavigationListener', (tester) async {
    final modularApp = ModularApp(
      module: CustomModule(),
      child: const AppWidget(),
    );
    await tester.pumpWidget(modularApp);

    await tester.pump();
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);

    final state = tester.state<NavigationListenerState>(find.byKey(key));
    state.listener();
  });
}

final key = UniqueKey();

class CustomModule extends Module {
  @override
  void binds(Injector i) => i.add((i) => 'test');

  @override
  void routes(RouteManager r) => r.add(
        ChildRoute(
          '/',
          child: (_) => NavigationListener(
              key: key,
              builder: (context, snapshot) {
                return Container();
              }),
        ),
      );
}

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
