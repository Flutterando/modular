import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';

enum ModularTestType { resetModules, keepModulesOnMemory }

abstract class IModularTest {
  final ModularTestType modularTestType;
  IModularTest({this.modularTestType: ModularTestType.resetModules});

  ChildModule get module;
  List<Bind> get binds;
  IModularTest get modulardependency;

  void load({
    IModularTest changedependency,
    List<Bind> changeBinds,
    bool isLoadDependency = true,
  }) {
    IModularTest dependency = getDendencies(
      changedependency,
      isLoadDependency,
    );
    List<Bind> binds = this.getBinds(changeBinds);
    memoryManage(this.modularTestType);
    this.loadModularDependency(isLoadDependency, changeBinds, dependency);

    initModule(
      this.module,
      changeBinds: binds,
      initialModule: this.isMainModule
    );
  }

  @visibleForTesting
  IModularTest getDendencies(
    IModularTest changedependency,
    bool isLoadDependency,
  ) {
    changedependency ??= this.modulardependency;

    assert(
      !_isDependencyRequired(changedependency, isLoadDependency),
      "Dependency must not be null when isLoadDependency is true",
    );
    return changedependency;
  }

  bool _isDependencyRequired(IModularTest dependency, bool isLoadDependency) =>
      dependency == null && isLoadDependency && isMainModule;

  @visibleForTesting
  List<Bind> getBinds(List<Bind> changeBinds) {
    final mergedChangeBinds = mergeBinds(changeBinds, this.binds);

    return mergedChangeBinds;
  }

  
  @visibleForTesting
  List<Bind> mergeBinds(List<Bind> changeBinds, List<Bind> defaultBinds) {
    final resultBinds = defaultBinds ?? [];

    for (var bind in (changeBinds ?? [])) {
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
    if (modularTestType == ModularTestType.resetModules)
      Modular.removeModule(this.module);
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

  bool get isMainModule => !(this.module is MainModule);
}
