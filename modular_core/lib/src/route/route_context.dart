import '../di/bind_context.dart';

import 'modular_route.dart';

abstract class RouteContext extends BindContext {
  List<ModularRoute> get routes => const [];
  final routeMap = <String, ModularRoute>{};

  RouteContext() {
    for (var route in routes) {
      routeMap.addAll(route.routeMap);
    }
  }
}
