import '../../core/models/modular_arguments.dart';
import '../../core/modules/child_module.dart';
import 'modular_navigator_interface.dart';

abstract class ModularInterface {
  bool get debugMode;
  ModularArguments? get args;
  String get initialRoute;
  ChildModule get initialModule;
  void init(ChildModule module);
  void bindModule(ChildModule module, [String path]);
  void debugPrintModular(String text);

  IModularNavigator get to;
  B? get<B extends Object>({
    Map<String, dynamic> params = const {},
    List<Type>? typesInRequestList,
    B? defaultValue,
  });

  void dispose<B>();
}
