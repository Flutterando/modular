import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular_test.dart';

import 'package:example/app/modules/tabs/tabs_page.dart';

main() {
  testWidgets('TabsPage has title', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(TabsPage(title: 'Tabs')));
    final titleFinder = find.text('Tabs');
    expect(titleFinder, findsOneWidget);
  });
}
