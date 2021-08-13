import '../../presenters/modular_route_impl.dart';
import '../interfaces/modular_route.dart';
import '../interfaces/module.dart';
import '../interfaces/route_guard.dart';
import 'custom_transition.dart';

class ModuleRoute extends ModularRouteImpl {
  ModuleRoute(
    String routerName, {
    required Module module,
    List<RouteGuard>? guards,
    TransitionType transition = TransitionType.defaultTransition,
    CustomTransition? customTransition,
    String? guardedRoute,
    RouteBuilder? routeGenerator,
    Duration duration = const Duration(milliseconds: 300),
  })  : assert(!routerName.contains('/:'), 'ModuleRoute should not contain dynamic route'),
        super(
          routerName,
          routerOutlet: [],
          duration: duration,
          routeGenerator: routeGenerator,
          module: module,
          customTransition: customTransition,
          guards: guards,
          transition: transition,
        );
}
