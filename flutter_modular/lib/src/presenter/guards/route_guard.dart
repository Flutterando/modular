import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:modular_core/modular_core.dart';

/// RouteGuard implements Middleware and adds guard behavior, authorizing or not the route via the canActivate() method;
abstract class RouteGuard extends Middleware<ModularArguments> {
  /// Returns a FutureOr<bool>.
  /// If TRUE, allow the route to continue processing.
  /// If it is FALSE, the Guard will try to redirect the route.
  /// If there is no redirect then an error will be thrown [GuardedRouteException].
  FutureOr<bool> canActivate(String path, ParallelRoute route);

  /// If the route is not allowed then the Guard will redirect to that route.
  final String? redirectTo;

  RouteGuard({this.redirectTo});

  @override
  FutureOr<ModularRoute?> pre(ModularRoute route) => route;

  @override
  FutureOr<ParallelRoute?> pos(route, args) async {
    if (await canActivate(args.uri.toString(), route as ParallelRoute)) {
      return route;
    } else if (redirectTo != null) {
      return RedirectRoute(route.name, to: redirectTo!);
    }

    throw GuardedRouteException(route.uri.toString().trim());
  }
}
