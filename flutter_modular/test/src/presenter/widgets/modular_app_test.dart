import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ModularApp', (tester) async {
    final modularKey = UniqueKey();
    final modularApp =
        ModularApp(key: modularKey, module: CustomModule(), child: AppWidget());
    await tester.pumpWidget(modularApp);

    await tester.pump();
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);

    final state = tester.state<ModularAppState>(find.byKey(modularKey));
    final result = state.tripleResolverCallback<String>();
    expect(result, 'test');
  });
}

final key = UniqueKey();

class CustomModule extends Module {
  @override
  List<Bind> get binds => [Bind.factory((i) => 'test')];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (_, __) => Container(key: key)),
      ];
}

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp().modular();
  }
}
