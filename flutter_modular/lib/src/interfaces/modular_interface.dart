import '../../flutter_modular.dart';

abstract class ModularInterface {
  bool get debugMode;

  String get initialRoute;
  IModularNavigator get navigatorDelegate;

  IModularNavigator get to;
  IModularNavigator get link;
  B get<B>(
      {Map<String, dynamic> params,
      String module,
      List<Type> typesInRequest,
      B defaultValue});
  void dispose<B>([String moduleName]);
}
