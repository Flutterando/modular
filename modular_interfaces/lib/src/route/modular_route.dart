import '../di/bind_context.dart';

import 'middleware.dart';
import 'modular_key.dart';
import 'route_context.dart';

abstract class ModularRoute {
  String get name;
  String get schema;
  String get parent;
  List<ModularRoute> get children;
  List<Middleware> get middlewares;
  Uri get uri;
  Map<Type, BindContext> get bindContextEntries;
  Map<ModularKey, ModularRoute> get routeMap;
  ModularKey get key;

  ModularRoute addModule(String name, {required RouteContext module});

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
