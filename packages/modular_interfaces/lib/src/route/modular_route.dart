import '../di/bind_context.dart';

import 'middleware.dart';
import 'modular_key.dart';
import 'route_context.dart';

/// Represents a route within a RouteContext.
abstract class ModularRoute {
  /// name of route
  String get name;

  /// schema of route
  /// default is ''
  String get schema;

  /// guard your parent's path
  String get parent;

  /// Add children to this route that can be retrieved through the parent route
  List<ModularRoute> get children;

  /// RouteContext belonging to the route.
  RouteContext? get context;

  /// Adds middleware that will be shared among your children.
  List<Middleware> get middlewares;

  /// Current uri of the route.
  Uri get uri;

  /// Contains a list of all BindContexts that will need to be active when this route is active.
  Map<Type, BindContext> get bindContextEntries;

  /// Key that references the route in the RouteContext tree.
  ModularKey get key;

  /// Create a new Route by adding a RouteContext to the context.
  ModularRoute addModule(String name, {required RouteContext module});

  ModularRoute copyWith({
    String? name,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    String? schema,
    RouteContext? context,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  });
}
