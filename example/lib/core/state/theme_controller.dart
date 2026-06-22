import 'package:flutter/material.dart';

/// App-scoped reactive state. NOT registered in DI — it is provided ABOVE the
/// `MaterialApp` by `ModularApp` in `main.dart` (`provide:`), which is what lets
/// it drive the app theme. A page-scoped VM (below the `Navigator`) could not.
class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;

  void toggle() {
    mode = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
