import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app/app_module.dart';

main() {
  testWidgets('Button is present and triggers navigation after tapped',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(ModularApp(
        module: AppModule(),
      ));

      await routerDelegate.pushNamed('/forbidden');
      await tester.pump();
      //how to test navigator?
      await Future.delayed(Duration(seconds: 2));
      Modular.to.pop('Teste pop');
      await tester.pump();
    });
  });
}
