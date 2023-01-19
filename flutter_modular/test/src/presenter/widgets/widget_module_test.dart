import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WidgetModule', (tester) async {
    final modularApp =
        ModularApp(module: CustomModule(), child: const AppWidget());
    await tester.pumpWidget(modularApp);

    await tester.pump();
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    expect(Modular.get<double>(), 0.0);

    final result =
        tester.widget<CustomWidgetModule>(find.byType(CustomWidgetModule));

    result.changeBinds(result.getProcessBinds());

    await result.isReady();
    result.remove();
    result.removeScopedBind();

    // final state = tester.state<NavigationListenerState>(find.byKey(key));
    // state.listener();
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
        ChildRoute('/', child: (_, __) => CustomWidgetModule()),
      ];
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

class CustomWidgetModule extends WidgetModule {
  CustomWidgetModule({Key? key}) : super(key: key);

  @override
  List<Bind> get binds => [
        Bind.factory<double>((i) {
          debugPrint(i.args.toString());
          return 0.0;
        }),
      ];

  @override
  Widget get view => Container(key: key);
}
