import '../models/modular_arguments.dart';
import 'module.dart';
import 'modular_navigator_interface.dart';

abstract class ModularInterface {
  bool get debugMode;
  ModularArguments? get args;
  String get initialRoute;
  Module get initialModule;
  void init(Module module);
  void bindModule(Module module, [String path]);
  void debugPrintModular(String text);

  IModularNavigator get to;
  B get<B extends Object>({
    Map<String, dynamic> params = const {},
    List<Type>? typesInRequestList,
    B? defaultValue,
  });

  bool dispose<B extends Object>();
}
