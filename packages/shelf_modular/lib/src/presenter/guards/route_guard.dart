import 'dart:async';

import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_modular/src/presenter/errors/errors.dart';
import 'package:shelf_modular/src/presenter/models/route.dart';

abstract class RouteGuard extends Middleware<shelf.Request> {
  FutureOr<bool> canActivate(shelf.Request request, Route route);

  @override
  FutureOr<ModularRoute?> pre(ModularRoute route) => route;

  @override
  FutureOr<Route?> pos(route, data) async {
    if (await canActivate(data, route as Route)) {
      return route;
    }

    throw GuardedRouteException(route.uri.toString().trim());
  }
}
