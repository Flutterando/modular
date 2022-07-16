import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ModularState', (tester) async {
    final modularApp =
        ModularApp(module: CustomModule(), child: const AppWidget());
    await tester.pumpWidget(modularApp);

    await tester.pump();
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
  });
}

final key = UniqueKey();

class CustomModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.factory((i) => 'test'),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (_, __) => HomeExample(key: key)),
      ];
}

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: Modular.routerDelegate,
      routeInformationParser: Modular.routeInformationParser,
    );
  }
}

class HomeExample extends StatefulWidget {
  const HomeExample({Key? key}) : super(key: key);

  @override
  _HomeExampleState createState() => _HomeExampleState();
}

// ignore: deprecated_member_use_from_same_package
class _HomeExampleState extends ModularState<HomeExample, String> {
  @override
  Widget build(BuildContext context) {
    debugPrint(cubit.toString());
    debugPrint(bloc.toString());
    debugPrint(store.toString());
    debugPrint(controller.toString());
    return Container();
  }
}
