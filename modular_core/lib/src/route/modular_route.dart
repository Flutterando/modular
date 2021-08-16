import 'package:modular_core/modular_core.dart';
import 'package:modular_core/src/di/bind_context.dart';

import 'route_context.dart';

abstract class ModularRoute {
  final String name;
  final String tag;
  final ModularRoute? parent;
  late final List<ModularRoute> children;
  final List<Middleware> middlewares;
  final Uri uri;
  final Map<Type, BindContext> bindContextEntries;
  late final Map<String, ModularRoute> routeMap;

  ModularRoute({
    required this.name,
    this.tag = '',
    List<ModularRoute> children = const [],
    this.parent,
    required this.uri,
    this.bindContextEntries = const {},
    this.middlewares = const [],
    Map<String, ModularRoute>? routeMap,
  }) {
    if (routeMap == null) {
      this.routeMap = {};
      this.children = children
          .map(
            (e) => e.copyWith(
              parent: this,
              //TODO: ver concatenacao de nomes
              name: '$name${e.name}',
              tag: uri.path,
              middlewares: [...middlewares, ...e.middlewares],
              bindContextEntries: Map.from(bindContextEntries)..addAll(e.bindContextEntries),
            ),
          )
          .toList();
      this.routeMap[name] = this;
      for (var child in this.children) {
        this.routeMap[child.name] = child;
      }
    } else {
      this.routeMap = routeMap;
      this.children = children;
    }
  }

  ModularRoute addModule(String name, {required RouteContext module}) {
    final bindContextEntries = {module.runtimeType: module};
    final routeMap = module.routeMap.map<String, ModularRoute>(
      (key, route) => MapEntry(
        name + key,
        route.copyWith(
          bindContextEntries: bindContextEntries,
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
    String? tag,
    List<Middleware> middlewares,
    List<ModularRoute>? children,
    ModularRoute? parent,
    Uri? uri,
    Map<String, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  });
}
