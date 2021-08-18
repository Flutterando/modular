import 'package:meta/meta.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

import 'route_context.dart';

abstract class Module extends RouteContextImpl {
  @visibleForOverriding
  @override
  List<Module> get imports => const [];

  @visibleForOverriding
  @override
  List<Bind> get binds => const [];

  @override
  List<ModularRoute> get routes => const [];
}
