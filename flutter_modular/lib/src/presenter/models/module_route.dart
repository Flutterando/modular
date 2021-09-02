import 'package:flutter_modular/src/presenter/guards/route_guard.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';

import 'module.dart';

class ModuleRoute extends ParallelRoute {
  factory ModuleRoute(
    String name, {
    required Module module,
    List<RouteGuard> guards = const [],
  }) {
    return ParallelRoute.module(
      name,
      module: module,
      middlewares: guards,
    ) as ModuleRoute;
  }
}
