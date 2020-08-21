import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter_modular/src/navigator/modular_navigator.dart';

class ModularNavigatorOutlet extends ModularNavigator {
  final NavigatorState global;
  final NavigatorState module;
  ModularNavigatorOutlet({this.module, this.global}) : super(module) {}

  @override
  void pop<T extends Object>([T result]) {
    if (module.canPop()) {
      module.pop();
    } else {
      global.pop();
    }
  }
}
