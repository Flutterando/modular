import 'package:modular_core/modular_core.dart';

import '../../../shelf_modular.dart';

extension RouteManagerExt on RouteManager {
  void get(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.get(name, handler, middlewares: middlewares));
  }

  void post(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.post(name, handler, middlewares: middlewares));
  }

  void put(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.put(name, handler, middlewares: middlewares));
  }

  void patch(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.path(name, handler, middlewares: middlewares));
  }

  void delete(
    String name,
    Function handler, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.delete(name, handler, middlewares: middlewares));
  }

  void resource(
    Resource resource, {
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.resource(resource, middlewares: middlewares));
  }

  void module(
    String name, {
    required Module module,
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.module(name, module: module, middlewares: middlewares));
  }

  void websocket(
    String name, {
    required WebSocketResource websocket,
    List<ModularMiddleware> middlewares = const [],
  }) {
    add(Route.websocket(name, websocket: websocket, middlewares: middlewares));
  }
}
