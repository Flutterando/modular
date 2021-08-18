import '../di/bind_context.dart';

import 'modular_route.dart';

abstract class RouteContext extends BindContext {
  List<ModularRoute> get routes;
}
