import 'dart:async';
import 'dart:convert';

import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_modular/src/presenter/models/route.dart';

///[RouteGuard] verifies if the request can be activated. In case
///of error, returns a forbidden [shelf] response, otherwise, returns
///a [shelf] handler.
abstract class RouteGuard extends ModularMiddleware {
  ///Receives a [shelf] request and a [Route]
  FutureOr<bool> canActivate(shelf.Request request, Route route);

  @override
  FutureOr<shelf.Response> Function(shelf.Request) call(
    shelf.Handler handler, [
    ModularRoute? route,
  ]) {
    return (request) async {
      if (!await canActivate(request, route! as Route)) {
        return shelf.Response.forbidden(
          jsonEncode({'error': route.uri.toString().trim()}),
        );
      }
      return handler(request);
    };
  }
}

///implements [Middleware]
///Act as a middleware between the [pre] route and [pos] route
abstract class ModularMiddleware implements Middleware<shelf.Request> {
  ///[ModularMiddleware] constructor
  const ModularMiddleware();

  @override
  FutureOr<ModularRoute?> pre(ModularRoute route) => route;

  @override
  FutureOr<Route?> pos(ModularRoute route, shelf.Request data) =>
      route as Route;

  ///Performs a [call] using a [handler] and a [ModularRoute]
  shelf.Handler call(shelf.Handler handler, [ModularRoute? route]);
}
