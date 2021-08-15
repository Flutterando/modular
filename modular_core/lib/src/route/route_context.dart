import '../di/bind_context.dart';

import 'route.dart';

abstract class RouteContext extends BindContext {
  List<Route> get routes => const [];
  final routeMap = <String, Route>{};

  RouteContext() {
    for (var route in routes) {
      routeMap.addAll(route.routeMap);
    }
  }
}
