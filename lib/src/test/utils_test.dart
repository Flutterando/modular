import 'package:flutter/material.dart';

import '../../flutter_modular.dart';

void initModule(ChildModule module, {List<Bind> changeBinds, bool initialModule, bool debugMode}) {
  Modular.debugMode = debugMode ?? false;
  final list = module.binds;
  for (var item in list ?? []) {
    var dep = (changeBinds ?? []).firstWhere((dep) {
      return item.runtimeType == dep.runtimeType;
    }, orElse: () => null);
    if (dep != null) {
      list.remove(item);
      list.add(dep);
      module.changeBinds(list);
    }
  }
  if (initialModule ?? false)
    Modular.init(module);
  else
    Modular.bindModule(module);
}

void initModules(List<ChildModule> modules, {List<Bind> changeBinds, bool debugMode}) {
  for (var module in modules) {
    initModule(module, changeBinds: changeBinds, debugMode: debugMode);
  }
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      home: widget,
      initialRoute: '/',
      navigatorKey: Modular.navigatorKey,
      onGenerateRoute: Modular.generateRoute,
    ),
  );
}
