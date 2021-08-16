import 'dart:async';

import '../../modular_core.dart';
import 'modular_route.dart';

abstract class Middleware {
  FutureOr<ModularRoute?> call(ModularRoute route);
}

abstract class RouteGuard extends Middleware {
  RouteGuard([this.guardedRoute]);

  final String? guardedRoute;

  FutureOr<bool> canActivate(String path, ModularRoute router);

  @override
  FutureOr<ModularRoute?> call(ModularRoute route) async {
    if (await canActivate(route.uri.toString(), route)) {
      return route;
    } else if (guardedRoute != null) {
      final redirect = await Tracker.findRoute(guardedRoute!);
      if (redirect != null) {
        return redirect;
      }
    }

    throw GuardedRouteException(route.uri.toString());
  }
}

class GuardedRouteException implements Exception {
  final String path;

  GuardedRouteException(this.path);

  @override
  String toString() {
    return 'GuardedRouteException: $path';
  }
}
