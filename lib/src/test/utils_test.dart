import 'package:flutter/material.dart';

import '../../flutter_modular.dart';

class TestModule extends ChildModule {
  final List<Bind> changeBinds;
  final List<Router> changeRouters;

  TestModule(this.changeBinds, this.changeRouters);

  @override
  List<Bind> get binds => changeBinds;

  @override
  List<Router> get routers => changeRouters;
}

void initModule(ChildModule module, {List<Bind> changeBinds}) {
  // ChildModule changedModule = TestModule(changeBinds, module.routers);

  for (var item in module.binds ?? []) {
    var dep = (changeBinds ?? []).firstWhere((dep) {
      return item.inject.runtimeType == dep.inject.runtimeType;
    }, orElse: () => null);
    if (dep != null) {
      module.binds.remove(dep);
      module.binds.add(item);
    }
  }

  Modular.addCoreInit(module);
}

void initModules(List<ChildModule> modules, {List<Bind> changeBinds}) {
  for (var module in modules) {
    initModule(module, changeBinds: changeBinds);
  }
}

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
}
