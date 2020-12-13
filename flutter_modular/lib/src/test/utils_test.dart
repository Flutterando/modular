import 'package:flutter/material.dart';

import '../core/inject/bind.dart';
import '../core/modules/child_module.dart';

void initModule(ChildModule module,
    {List<Bind> changeBinds = const [], bool initialModule = false}) {
  //Modular.debugMode = false;
  final list = module.binds;
  final changedList = List<Bind>.from(list);
  for (var item in list) {
    var dep = (changeBinds).firstWhere((dep) {
      return item.runtimeType == dep.runtimeType;
    }, orElse: () => BindEmpty());
    if (dep is BindEmpty) {
      changedList.remove(item);
      changedList.add(dep);
    }
  }
  module.changeBinds(changedList);
  if (initialModule) {
    //  Modular.init(module);
  } else {
    //  Modular.bindModule(module);
  }
}

void initModules(List<ChildModule> modules,
    {List<Bind> changeBinds = const []}) {
  for (var module in modules) {
    initModule(module, changeBinds: changeBinds);
  }
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      home: widget,
      initialRoute: '/',
      //    navigatorKey: Modular.navigatorKey,
      //    onGenerateRoute: Modular.generateRoute,
    ),
  );
}
