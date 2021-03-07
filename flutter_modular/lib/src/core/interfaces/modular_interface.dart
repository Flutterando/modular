import '../models/bind.dart';

import '../models/modular_arguments.dart';
import 'modular_navigator_interface.dart';
import 'module.dart';

abstract class ModularInterface {
  bool get debugMode;
  ModularArguments? get args;
  String get initialRoute;
  Module get initialModule;
  void init(Module module);
  void bindModule(Module module, [String path]);
  void debugPrintModular(String text);
  T read<T extends Object>(Bind<T> bind);

  IModularNavigator get to;
  B get<B extends Object>({
    List<Type>? typesInRequestList,
    B? defaultValue,
  });

  bool dispose<B extends Object>();
}
