library modular_test;

import 'package:modular_core/modular_core.dart';

void initModule(BindContext module, {List<BindContract> replaceBinds = const []}) {
  // ignore: invalid_use_of_visible_for_testing_member
  final bindModules = module.getProcessBinds();

  for (var i = 0; i < bindModules.length; i++) {
    final item = bindModules[i];
    var dep = (replaceBinds).firstWhere((dep) {
      return item.runtimeType == dep.runtimeType;
    }, orElse: () => BindEmpty());
    if (dep is! BindEmpty) {
      bindModules[i] = dep;
    }
  }
  module.changeBinds(bindModules);
  modularTracker.injector.addBindContext(module);
}

void initModules(List<BindContext> modules, {List<BindContract> replaceBinds = const []}) {
  for (var module in modules) {
    initModule(module, replaceBinds: replaceBinds);
  }
}
