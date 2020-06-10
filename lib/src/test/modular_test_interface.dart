import 'package:flutter/material.dart';
import '../../flutter_modular.dart';
import '../../flutter_modular_test.dart';

enum ModularTestType { resetModules, keepModulesOnMemory }

abstract class IModularTest {
  final ModularTestType modularTestType;
  IModularTest({this.modularTestType = ModularTestType.resetModules});

  ChildModule get module;
  List<Bind> get binds;
  IModularTest get modulardependency;

  void load({
    IModularTest changedependency,
    List<Bind> changeBinds,
    bool isLoadDependency = true,
  }) {
    final dependency = getDendencies(
      changedependency: changedependency,
      isLoadDependency: isLoadDependency,
    );
    final binds = getBinds(changeBinds);
    memoryManage(modularTestType);
    loadModularDependency(
      isLoadDependency: isLoadDependency,
      changeBinds: changeBinds,
      dependency: dependency,
    );

    initModule(module, changeBinds: binds, initialModule: isMainModule);
  }

  @visibleForTesting
  IModularTest getDendencies({
    IModularTest changedependency,
    @required bool isLoadDependency,
  }) {
    changedependency ??= modulardependency;

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
    final mergedChangeBinds = mergeBinds(changeBinds, binds);

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
    if (modularTestType == ModularTestType.resetModules) {
      Modular.removeModule(module);
    }
  }

  @visibleForTesting
  void loadModularDependency({
    @required bool isLoadDependency,
    @required List<Bind> changeBinds,
    @required IModularTest dependency,
  }) {
    if (isLoadDependency && dependency != null) {
      dependency.load(changeBinds: changeBinds);
    }
  }

  bool get isMainModule => !(module is MainModule);
}
