// import '../../flutter_modular.dart';

import 'package:flutter/material.dart';

import '../../flutter_modular.dart';
import 'utils_test.dart';

enum ModularTestType { resetModule, keepModulesOnMemory }

abstract class IModularTest {
  final ModularTestType modularTestType;
  IModularTest({this.modularTestType: ModularTestType.resetModule});

  ChildModule module();
  List<Bind> binds();
  IModularTest modulardependency();

  void load({
    IModularTest changedependency,
    List<Bind> changeBinds,
    bool isLoadDependency = true,
  }) {
    IModularTest dependency = getNewOrDefaultDendencies(
      changedependency,
      isLoadDependency,
    );
    List<Bind> binds = this.getNewOrDefaultBinds(changeBinds);

    memoryManage(this.modularTestType);
    this.loadModularDependency(isLoadDependency, dependency);
    initModule(
      this.module(),
      changeBinds: binds,
    );
  }

  @visibleForTesting
  IModularTest getNewOrDefaultDendencies(
    IModularTest changedependency,
    bool isLoadDependency,
  ) {
    changedependency ??= this.modulardependency();

    assert(
      !_isDependencyRequired(changedependency, isLoadDependency),
      "Dependency must not be null when isLoadDependency is true",
    );
    return changedependency;
  }

  bool _isDependencyRequired(IModularTest dependency, bool isLoadDependency) =>
      dependency == null && isLoadDependency && isMainModule;

  @visibleForTesting
  List<Bind> getNewOrDefaultBinds(List<Bind> changeBinds) {
    changeBinds ??= this.binds();
    assert(
      changeBinds != null,
      "changeBinds must not be null",
    );

    return changeBinds;
  }

  @visibleForTesting
  void memoryManage(ModularTestType modularTestType) {
    if (modularTestType == ModularTestType.resetModule)
      Modular.removeModule(this.module());
  }

  @visibleForTesting
  void loadModularDependency(
    bool isLoadDependency,
    IModularTest dependency,
  ) {
    if (isLoadDependency && dependency != null) {
      dependency.load();
    }
  }

  bool get isMainModule => !(this.module() is MainModule);
}
