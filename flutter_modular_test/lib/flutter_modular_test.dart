library flutter_modular_test;

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void initModule(Module module, {List<Bind<Object>> replaceBinds = const [], bool initialModule = false}) {
  for (var i = 0; i < module.binds.length; i++) {
    final item = module.binds[i];
    var dep = (replaceBinds).firstWhere((dep) {
      return item.runtimeType == dep.runtimeType;
    }, orElse: () => BindEmpty());
    if (dep is! BindEmpty) {
      module.binds[i] = dep;
    }
  }
  //module.changeBinds(changedList);
  if (initialModule) {
    Modular.init(module);
  } else {
    Modular.bindModule(module);
  }
}

void initModules(List<Module> modules, {List<Bind<Object>> replaceBinds = const []}) {
  for (var module in modules) {
    initModule(module, replaceBinds: replaceBinds);
  }
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      home: widget,
    ),
  );
}
