import 'package:flutter/widgets.dart';

import '../../presenters/modular_route_impl.dart';
import '../interfaces/modular_route.dart';
import '../interfaces/route_guard.dart';
import 'custom_transition.dart';
import 'modular_arguments.dart';

class ChildRoute extends ModularRouteImpl {
  ChildRoute(
    String routerName, {
    List<ModularRoute> children = const [],
    required Widget Function(BuildContext, ModularArguments?) child,
    List<RouteGuard>? guards,
    TransitionType transition = TransitionType.defaultTransition,
    CustomTransition? customTransition,
    RouteBuilder? routeGenerator,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(routerName,
            routerOutlet: [],
            duration: duration,
            child: child,
            routeGenerator: routeGenerator,
            customTransition: customTransition,
            children: children,
            guards: guards,
            transition: transition);
}
