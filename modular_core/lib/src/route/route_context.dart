import '../di/bind_context.dart';

import 'modular_route.dart';

typedef RouteResolver = ModularRoute Function(dynamic arg);

abstract class RouteContext extends BindContext {
  List<ModularRoute> get routes => const [];
  final _routeMap = <String, ModularRoute>{};

  RouteContext() {
    for (var route in routes) {
      if (route.children.isEmpty) {
        _routeMap[route.name] = route;
      } else {
        for (var child in route.children) {
          _routeMap[route.name];
        }
      }
    }
  }
}
