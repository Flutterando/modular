import 'package:flutter/material.dart';
import '../../../flutter_modular.dart';

import '../models/bind.dart';

import '../models/modular_arguments.dart';
import 'modular_navigator_interface.dart';
import 'module.dart';

abstract class ModularInterface {
  IModularNavigator? navigatorDelegate;

  bool get debugMode;
  ModularFlags get flags;
  ModularArguments? get args;
  String get initialRoute;
  Module get initialModule;
  @visibleForTesting
  void overrideBinds(List<Bind> binds);
  void init(Module module);
  void bindModule(Module module, [String path]);
  void debugPrintModular(String text);
  T bind<T extends Object>(Bind<T> bind);

  IModularNavigator get to;
  B get<B extends Object>({
    List<Type>? typesInRequestList,
    B? defaultValue,
  });

  bool dispose<B extends Object>();
}
