import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

main() {
  test('Initialized MaterialApp.modular sintaxe', () {
    final theme = ThemeData.dark();
    final app = MaterialApp(
      theme: theme,
    ).modular();
    expect(app.theme, theme);
  });
}
