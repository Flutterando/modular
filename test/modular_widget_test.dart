import 'package:flutter_test/flutter_test.dart';
import 'package:modular/modular.dart';

import 'app/app_module.dart';

main() {
  setUpAll(() {});

  group("Init module widget", () {
    testWidgets('ModularWidget', (WidgetTester tester) async {
      await tester.pumpWidget(ModularWidget(module: AppModule(),));
      final textInject = find.text('testing inject');
      expect(textInject, findsOneWidget);
    });
  });
}
