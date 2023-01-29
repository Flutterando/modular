import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart' hide Middleware;
import 'package:shelf_modular/shelf_modular.dart';

class Route extends ModularRoute {
  final Function? handler;

  Route._(
    super.name, {
    this.handler,
    super.parent = '',
    super.schema = '',
    super.children = const [],
    Uri? uri,
    super.module,
    super.middlewares = const [],
    super.innerModules = const {},
  }) : super(uri: uri ?? Uri.parse('/'));

  factory Route.get(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      name,
      handler: handler,
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
      name,
      handler: handler,
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
      name,
      handler: handler,
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
      name,
      handler: handler,
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
      name,
      handler: handler,
      schema: 'PUT',
      middlewares: middlewares,
    );
  }

  factory Route.resource(
    Resource resource, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      '/',
      children: resource.routes,
      middlewares: middlewares,
    );
  }

  factory Route.module(String name,
      {required Module module,
      List<ModularMiddleware> middlewares = const []}) {
    final route = Route._(name, middlewares: middlewares);
    return route.addModule(name, module: module);
  }

  factory Route.websocket(
    String name, {
    required WebSocketResource websocket,
    List<ModularMiddleware> middlewares = const [],
  }) {
    return Route._(
      name,
      handler: websocket.handler,
      schema: 'GET',
      middlewares: middlewares,
    );
  }

  @override
  Route copyWith({
    Handler? handler,
    String? name,
    String? schema,
    Module? module,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, Module>? innerModules,
  }) {
    return Route._(
      name ?? this.name,
      handler: handler ?? this.handler,
      schema: schema ?? this.schema,
      middlewares: (middlewares ?? this.middlewares),
      children: children ?? this.children,
      parent: parent ?? this.parent,
      module: module ?? this.module,
      uri: uri ?? uri,
      innerModules: innerModules ?? this.innerModules,
    );
  }

  @override
  Route addModule(String name, {required Module module}) {
    final innerModules = {module.runtimeType: module};

    return copyWith(
      name: name,
      uri: Uri.parse(name),
      innerModules: innerModules,
      module: module,
    );
  }
}
