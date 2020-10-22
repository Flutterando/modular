import 'package:flutter/material.dart';
import 'package:flutter_modular/src/delegates/modular_route_path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

main() {
  test('check initial route', () {});

  testWidgets('Button is present and triggers navigation after tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
    ).modular());

    routerDelegate.handleBookTapped();
    //how to test navigator?

    await tester.pump();
    await tester.pumpAndSettle();
    Modular.to.pop();
    await tester.pump();
  });
}
