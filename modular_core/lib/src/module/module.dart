import '../di/bind.dart';
import '../route/route.dart';

abstract class Module {
  List<Module> get imports => [];

  List<Bind> get binds => [];

  List<Bind> get exportedBinds => [];

  List<ModularRoute> get routes => [];
}
