import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';

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
    this.loadModularDependency(isLoadDependency, changeBinds, dependency);

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
    final mergedChangeBinds = _mergeBinds(changeBinds, this.binds());

    return mergedChangeBinds;
  }

  //b has priority
  List<Bind> _mergeBinds(List<Bind> src, List<Bind> dest) {
    final resultBinds = dest ?? [];

    for (var bind in (src ?? [])) {
      var changedBind = resultBinds.firstWhere(
        (item) => item.runtimeType == bind.runtimeType,
        orElse: () => null,
      );

      if (changedBind != null) resultBinds.remove(changedBind);
      resultBinds.add(bind);
    }

    return resultBinds;
  }

  @visibleForTesting
  void memoryManage(ModularTestType modularTestType) {
    if (modularTestType == ModularTestType.resetModule)
      Modular.removeModule(this.module());
  }

  @visibleForTesting
  void loadModularDependency(
    bool isLoadDependency,
    List<Bind> changeBinds,
    IModularTest dependency,
  ) {
    if (isLoadDependency && dependency != null) {
      dependency.load(changeBinds: changeBinds);
    }
  }

  bool get isMainModule => !(this.module() is MainModule);
}
