import 'package:flutter_modular/src/presenter/guards/route_guard.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';

class ChildRoute<T> extends ParallelRoute<T> {
  ChildRoute(
    String name, {
    required ModularChild child,
    CustomTransition? customTransition,
    List<ParallelRoute> children = const [],
    Duration duration = const Duration(milliseconds: 300),
    TransitionType transition = TransitionType.defaultTransition,
    List<RouteGuard> guards = const [],
  })  : assert(children.where((e) => e.name == name).isEmpty, 'Don\'t use name "/" in route\'s children when parent be "/" too'),
        super(
          name: name,
          child: child,
          customTransition: customTransition,
          children: children,
          duration: duration,
          transition: transition,
          middlewares: guards,
        );
}
