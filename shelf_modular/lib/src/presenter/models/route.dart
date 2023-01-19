import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart' hide Middleware;
import 'package:shelf_modular/shelf_modular.dart';

class Route extends ModularRouteImpl {
  final Function? handler;

  Route._({
    this.handler,
    required super.name,
    super.parent = '',
    super.schema = '',
    super.children = const [],
    Uri? uri,
    super.context,
    super.middlewares = const [],
    super.bindContextEntries = const {},
  }) : super(uri: uri ?? Uri.parse('/'));

  factory Route.get(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      handler: handler,
      name: name,
      schema: 'GET',
      middlewares: middlewares,
    );
  }

  factory Route.post(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      handler: handler,
      name: name,
      schema: 'POST',
      middlewares: middlewares,
    );
  }

  factory Route.delete(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      handler: handler,
      name: name,
      schema: 'DELETE',
      middlewares: middlewares,
    );
  }
  factory Route.path(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      handler: handler,
      name: name,
      schema: 'PATCH',
      middlewares: middlewares,
    );
  }

  factory Route.put(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      handler: handler,
      name: name,
      schema: 'PUT',
      middlewares: middlewares,
    );
  }

  factory Route.resource(
    Resource resource, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      name: '/',
      children: resource.routes,
      middlewares: middlewares,
    );
  }

  factory Route.module(String name,
      {required Module module,
      List<ModularMiddleware> middlewares = const []}) {
    final route = Route._(name: name, middlewares: middlewares);
    return route.addModule(name, module: module) as Route;
  }

  factory Route.websocket(
    String name, {
    required WebSocketResource websocket,
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      handler: websocket.handler,
      name: name,
      schema: 'GET',
      middlewares: middlewares,
    );
  }

  @override
  Route copyWith({
    Handler? handler,
    String? name,
    String? schema,
    RouteContext? context,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  }) {
    return Route._(
      handler: handler ?? this.handler,
      name: name ?? this.name,
      schema: schema ?? this.schema,
      middlewares: (middlewares ?? this.middlewares),
      children: children ?? this.children,
      parent: parent ?? this.parent,
      context: context ?? this.context,
      uri: uri ?? uri,
      bindContextEntries: bindContextEntries ?? this.bindContextEntries,
    );
  }
}
