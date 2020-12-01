import '../../flutter_modular.dart';

abstract class ModularInterface {
  bool get debugMode;

  String get initialRoute;
  ChildModule get initialModule;
  void init(ChildModule module);
  void bindModule(ChildModule module, [String path]);
  void debugPrintModular(String text);

  IModularNavigator get to;
  IModularNavigator get link;
  B? get<B>({
    Map<String, dynamic> params = const {},
    List<Type> typesInRequest = const [],
    B? defaultValue,
  });
  void dispose<B>();
}
