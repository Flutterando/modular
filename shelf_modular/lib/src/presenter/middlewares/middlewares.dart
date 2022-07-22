import 'dart:async';
import 'dart:convert';

import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_modular/src/presenter/models/route.dart';

abstract class RouteGuard extends ModularMiddleware {
  FutureOr<bool> canActivate(shelf.Request request, Route route);

  @override
  FutureOr<shelf.Response> Function(shelf.Request) call(shelf.Handler handler,
      [ModularRoute? route]) {
    return (request) async {
      if (!await canActivate(request, route as Route)) {
        return shelf.Response.forbidden(
            jsonEncode({'error': route.uri.toString().trim()}));
      }
      return handler(request);
    };
  }
}

abstract class ModularMiddleware implements Middleware<shelf.Request> {
  const ModularMiddleware();

  @override
  FutureOr<ModularRoute?> pre(ModularRoute route) => route;

  @override
  FutureOr<Route?> pos(route, data) => route as Route;

  shelf.Handler call(shelf.Handler handler, [ModularRoute? route]);
}
