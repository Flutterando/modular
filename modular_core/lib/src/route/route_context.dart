import 'package:meta/meta.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

import '../di/bind_context.dart';

abstract class RouteContextImpl extends BindContextImpl implements RouteContext {
  @override
  List<ModularRoute> get routes => const [];
  final _routeMap = <ModularKey, ModularRoute>{};

  @internal
  Map<ModularKey, ModularRoute> get routeMap => _routeMap;

  RouteContextImpl() {
    List<ModularRoute> ordenateRoutes = [...routes];
    ordenateRoutes.sort((preview, actual) {
      return preview.name.contains('/:') ? 1 : 0;
    });

    for (var route in ordenateRoutes) {
      _routeMap.addAll(route.routeMap);
    }
  }
}
