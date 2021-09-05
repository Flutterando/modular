import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'bind.dart';

/// /// A Module gathers all Binds and Routes referring to this context.
/// They are usually distributed in the form of features or a monolithic representation of the app.
/// At least one module is needed to start a Modular project.
class Module extends RouteContextImpl {
  @override
  List<Module> get imports => const [];

  @override
  List<Bind> get binds => const [];

  @override
  List<ModularRoute> get routes => const [];
}
