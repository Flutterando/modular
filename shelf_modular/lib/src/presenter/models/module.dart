import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'bind.dart';

class Module extends RouteContextImpl {
  @override
  List<Module> get imports => const [];

  @override
  List<Bind> get binds => const [];

  @override
  List<ModularRoute> get routes => const [];

  T i<T extends Object>() => Modular.get<T>();
}
