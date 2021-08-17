import 'package:modular_core/modular_core.dart';
import 'package:modular_core/src/di/bind_context.dart';

import 'modular_key.dart';
import 'route_context.dart';

abstract class ModularRoute {
  final String name;
  final String schema;
  final String parent;
  late final List<ModularRoute> children;
  final List<Middleware> middlewares;
  final Uri uri;
  final Map<Type, BindContext> bindContextEntries;
  late final Map<ModularKey, ModularRoute> routeMap;
  late final ModularKey key;

  ModularRoute({
    required this.name,
    this.parent = '',
    this.schema = '',
    List<ModularRoute> children = const [],
    required this.uri,
    this.bindContextEntries = const {},
    this.middlewares = const [],
    Map<ModularKey, ModularRoute>? routeMap,
  }) {
    key = ModularKey(name: name, schema: schema);
    if (routeMap == null) {
      this.routeMap = {};
      this.routeMap[key] = this;
      this.children = children
          .map(
            (e) => e.copyWith(
              parent: name,
              name: '$name${e.name}'.replaceAll('//', '/'),
              middlewares: [...middlewares, ...e.middlewares],
              bindContextEntries: Map.from(bindContextEntries)..addAll(e.bindContextEntries),
            ),
          )
          .toList();
      for (var child in this.children) {
        assert(name != child.name, 'Children can\'t have same name of parent. (parent: $name == child: ${child.name}');
        this.routeMap[child.key] = child;
      }
    } else {
      this.routeMap = routeMap;
      this.children = children;
    }
  }

  ModularRoute addModule(String name, {required RouteContext module}) {
    final bindContextEntries = {module.runtimeType: module};
    final routeMap = module.routeMap.map<ModularKey, ModularRoute>(
      (key, route) => MapEntry(
        key.copyWith(name: name + key.name),
        route.copyWith(
          name: '$name$key'.replaceAll('//', '/'),
          parent: route.parent != '' ? '$name${route.parent}'.replaceAll('//', '/') : route.parent,
          bindContextEntries: {...route.bindContextEntries, ...bindContextEntries},
          middlewares: [...middlewares, ...route.middlewares],
        ),
      ),
    );

    return copyWith(
      name: name,
      uri: Uri.parse(name),
      bindContextEntries: bindContextEntries,
      routeMap: routeMap,
    );
  }

  ModularRoute copyWith({
    String? name,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    String? schema,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  });
}
