import 'package:flutter_modular/src/presenter/guards/route_guard.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';

class ChildRoute extends ParallelRoute {
  factory ChildRoute(
    String name, {
    required ModularChild child,
    CustomTransition? customTransition,
    List<ParallelRoute> children = const [],
    Duration duration = const Duration(milliseconds: 300),
    TransitionType transition = TransitionType.defaultTransition,
    List<RouteGuard> guards = const [],
  }) {
    return ParallelRoute.child(
      name,
      child: child,
      children: children,
      duration: duration,
      transition: transition,
      middlewares: guards,
    ) as ChildRoute;
  }
}
