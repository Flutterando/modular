import 'package:flutter_modular/flutter_modular.dart';

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
  B? get<B>({
    Map<String, dynamic> params = const {},
    List<Type> typesInRequest = const [],
    B? defaultValue,
  });

  void dispose<B>();
}
