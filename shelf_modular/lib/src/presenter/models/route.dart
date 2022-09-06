import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart' hide Middleware;
import 'package:shelf_modular/shelf_modular.dart';

///[Route] object
///object base for all of route variations
class Route extends ModularRouteImpl {
  ///Instantiate a Function [handler]
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

  ///[Route] responsible for the get request
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

  ///[Route] responsible for the post request
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

  ///[Route] responsible for the delete request
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

  ///[Route] responsible for the patch request

  factory Route.patch(
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

  ///[Route] responsible for the put request

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

///[Route] responsible for the resource
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

///[Route] responsible for creating the route and adding the module
///in it.
  factory Route.module(
    String name, {
    required Module module,
    List<ModularMiddleware> middlewares = const [],
  }) {
    final route = Route._(name: name, middlewares: middlewares);
    return route.addModule(name, module: module) as Route;
  }

///[Route] responsible for creating the route with a [WebSocketResource]
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
      middlewares: middlewares ?? this.middlewares,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      context: context ?? this.context,
      uri: uri ?? uri,
      bindContextEntries: bindContextEntries ?? this.bindContextEntries,
    );
  }
}
