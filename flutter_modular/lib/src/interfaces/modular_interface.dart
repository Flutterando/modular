import 'package:flutter/foundation.dart';

import '../../flutter_modular.dart';

abstract class ModularInterface {
  bool debugMode = !kReleaseMode;
  IModularNavigator navigatorDelegate;

  IModularNavigator get to;
  IModularNavigator get link;
  B get<B>(
      {Map<String, dynamic> params,
      String module,
      List<Type> typesInRequest,
      B defaultValue});
  void dispose<B>([String moduleName]);
}
