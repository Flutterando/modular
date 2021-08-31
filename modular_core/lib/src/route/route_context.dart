import 'package:meta/meta.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

import '../di/bind_context.dart';

abstract class RouteContextImpl extends BindContextImpl implements RouteContext {
  @override
  List<ModularRoute> get routes => const [];
  final _routeMap = <ModularKey, ModularRoute>{};

  @internal
  Map<ModularKey, ModularRoute> get routeMap => _routeMap;

  @visibleForTesting
  List<ModularKey> orderRouteKeys(List<ModularKey> keys) {
    List<ModularKey> ordenatekeys = [...keys];
    ordenatekeys.sort((preview, actual) {
      if (preview.name.contains('/:') && !actual.name.contains('**')) {
        return 1;
      }

      if (preview.name.contains('**')) {
        if (!actual.name.contains('**')) {
          return 1;
        } else if (actual.name.split('/').length > preview.name.split('/').length) {
          return 1;
        }
      }

      return 0;
    });
    return ordenatekeys;
  }

  RouteContextImpl() {
    final localRouteMap = <ModularKey, ModularRoute>{};
    for (var route in routes) {
      localRouteMap.addAll(route.routeMap);
    }

    final keyList = orderRouteKeys(localRouteMap.keys.toList());
    for (var key in keyList) {
      _routeMap[key] = localRouteMap[key]!;
    }
  }
}
