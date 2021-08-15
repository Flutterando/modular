import 'package:meta/meta.dart';

import '../di/bind_context.dart';

import 'modular_route.dart';

abstract class RouteContext extends BindContext {
  List<ModularRoute> get routes => const [];
  final _routeMap = <String, ModularRoute>{};

  @internal
  Map<String, ModularRoute> get routeMap => _routeMap;

  RouteContext() {
    for (var route in routes) {
      _routeMap.addAll(route.routeMap);
    }
  }
}
