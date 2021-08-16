import 'package:meta/meta.dart';

import '../di/bind_context.dart';

import 'modular_route.dart';

abstract class RouteContext extends BindContext {
  List<ModularRoute> get routes => const [];
  final _routeMap = <String, ModularRoute>{};

  @internal
  Map<String, ModularRoute> get routeMap => _routeMap;

  RouteContext() {
    List<ModularRoute> ordenateRoutes = [...routes];
    ordenateRoutes.sort((preview, actual) {
      return preview.name.contains('/:') ? 1 : 0;
    });

    for (var route in ordenateRoutes) {
      _routeMap.addAll(route.routeMap);
    }
  }
}
