import 'package:meta/meta.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

import '../di/bind_context.dart';

///Abstract class [RouteContextImpl], implements the context of a route
abstract class RouteContextImpl extends BindContextImpl
    implements RouteContext {
  @override
  List<ModularRoute> get routes => const [];

  @override
  final List<RouteContext> modules = [];

  ///Ordernate the route keys in [ModularKey]
  @visibleForTesting
  List<ModularKey> orderRouteKeys(Iterable<ModularKey> keys) {
    final ordenatekeys = <ModularKey>[...keys]..sort((preview, actual) {
        if (preview.name.contains('/:') && !actual.name.contains('**')) {
          return 1;
        }

        if (preview.name.contains('**')) {
          if (!actual.name.contains('**')) {
            return 1;
          } else if (actual.name.split('/').length >
              preview.name.split('/').length) {
            return 1;
          }
        }

        return 0;
      });
    return ordenatekeys;
  }

  @override
  Map<ModularKey, ModularRoute> init() {
    modules
      ..clear()
      ..add(this);
    final _routeMap = <ModularKey, ModularRoute>{};
    for (final route in routes) {
      _routeMap.addAll(assembleRoute(route));
    }

    final _odernatedMap = <ModularKey, ModularRoute>{};
    for (final key in orderRouteKeys(_routeMap.keys)) {
      _odernatedMap[key] = _routeMap[key]!;
    }
    return _odernatedMap;
  }

  ///Checks the context in [route], is it's null, add to [Map]
  /// a child route, otherwise, adds a module route.
  @visibleForTesting
  Map<ModularKey, ModularRoute> assembleRoute(ModularRoute route) {
    final map = <ModularKey, ModularRoute>{};

    if (route.context == null) {
      map[route.key] = route;
      map.addAll(addChildren(route));
    } else {
      map.addAll(addModule(route));
    }

    return map;
  }

  ///Creates a [Map] and a module with the context from [route]
  ///adds the module in [modules] list, adds the [assembleRoute] intp the map
  ///and returns it
  @visibleForTesting
  Map<ModularKey, ModularRoute> addModule(ModularRoute route) {
    final map = <ModularKey, ModularRoute>{};
    final module = route.context!;
    modules.add(module);
    for (var child in module.routes) {
      child = child.copyWith(
        bindContextEntries: {module.runtimeType: module},
        parent: route.parent,
      );
      child = copy(route, child);
      map.addAll(assembleRoute(child));
    }

    return map;
  }

  ///Adds child routes into a [Map]
  @visibleForTesting
  Map<ModularKey, ModularRoute> addChildren(ModularRoute route) {
    final map = <ModularKey, ModularRoute>{};

    for (var child in route.children) {
      child = child.copyWith(parent: route.name);
      child = copy(route, child);
      map.addAll(assembleRoute(child));
    }

    return map;
  }

  ///Creates a new name with the [parent] and [route] names
  ///[copy] the route, adding the new name to it
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
