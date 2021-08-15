import 'package:meta/meta.dart';

import '../../modular_core.dart';
import 'route_context.dart';

abstract class Module extends RouteContext {
  @visibleForOverriding
  @override
  List<Module> get imports => const [];

  @visibleForOverriding
  @override
  List<Bind> get binds => const [];

  @override
  List<ModularRoute> get routes => const [];
}
