import '../../modular_core.dart';

class CustomRoute extends ModularRouteImpl {
  final dynamic data;

  CustomRoute({
    required String name,
    this.data,
    String parent = '',
    String schema = '',
    RouteContext? context,
    List<ModularRoute> children = const [],
    Uri? uri,
    List<Middleware> middlewares = const [],
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext> bindContextEntries = const {},
  }) : super(
          name: name,
          schema: schema,
          children: children,
          uri: uri ?? Uri.parse('/'),
          middlewares: middlewares,
          parent: parent,
          context: context,
          bindContextEntries: bindContextEntries,
        );

  factory CustomRoute.module(String name,
      {required RouteContext module, List<Middleware> middlewares = const []}) {
    final route = CustomRoute(name: name, middlewares: middlewares);
    return route.addModule(name, module: module) as CustomRoute;
  }

  @override
  ModularRoute copyWith({
    String? name,
    List<Middleware>? middlewares,
    String? parent,
    String? schema,
    RouteContext? context,
    List<ModularRoute>? children,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  }) {
    return CustomRoute(
      data: data,
      name: name ?? this.name,
      children: children ?? this.children,
      middlewares: middlewares ?? this.middlewares,
      uri: uri ?? this.uri,
      schema: schema ?? this.schema,
      context: context ?? this.context,
      parent: parent ?? this.parent,
      bindContextEntries: bindContextEntries ?? this.bindContextEntries,
    );
  }
}
