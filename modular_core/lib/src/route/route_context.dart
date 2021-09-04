import 'package:meta/meta.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

import '../di/bind_context.dart';

abstract class RouteContextImpl extends BindContextImpl implements RouteContext {
  @override
  List<ModularRoute> get routes => const [];

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

  @override
  Map<ModularKey, ModularRoute> init() {
    final _routeMap = <ModularKey, ModularRoute>{};
    for (var route in routes) {
      _routeMap.addAll(assembleRoute(route));
    }

    return _routeMap;
  }

  @visibleForTesting
  Map<ModularKey, ModularRoute> assembleRoute(ModularRoute route) {
    final Map<ModularKey, ModularRoute> map = {};

    if (route.context == null) {
      map[route.key] = route;
      map.addAll(addChildren(route));
    } else {
      map.addAll(addModule(route));
    }

    return map;
  }

  @visibleForTesting
  Map<ModularKey, ModularRoute> addModule(ModularRoute route) {
    final Map<ModularKey, ModularRoute> map = {};
    final module = route.context!;
    for (var child in module.routes) {
      child = child.copyWith(bindContextEntries: {module.runtimeType: module}, parent: route.parent);
      child = copy(route, child);
      map.addAll(assembleRoute(child));
    }

    final replicationKey = map.keys.firstWhere((key) => key.name == '${route.name}/', orElse: () => ModularKey(name: ''));
    if (replicationKey.name.isNotEmpty) {
      map[replicationKey.copyWith(name: route.name)] = map[replicationKey]!;
    }

    return map;
  }

  @visibleForTesting
  Map<ModularKey, ModularRoute> addChildren(ModularRoute route) {
    final Map<ModularKey, ModularRoute> map = {};

    for (var child in route.children) {
      child = child.copyWith(parent: route.name);
      child = copy(route, child);
      map.addAll(assembleRoute(child));
    }

    return map;
  }

  @visibleForOverriding
  ModularRoute copy(ModularRoute parent, ModularRoute route) {
    final newName = '${parent.name}${route.name}'.replaceFirst('//', '/');
    return route.copyWith(
      name: newName,
      middlewares: [
        ...parent.middlewares,
        ...route.middlewares,
      ],
      bindContextEntries: {
        ...parent.bindContextEntries,
        ...route.bindContextEntries,
      },
    );
  }
}
