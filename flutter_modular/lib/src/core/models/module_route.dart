import '../interfaces/route_guard.dart';
import '../modules/child_module.dart';

import 'modular_route.dart';

class ModuleRoute extends ModularRoute {
  ModuleRoute(
    String routerName, {
    required ChildModule module,
    List<RouteGuard>? guards,
    TransitionType transition = TransitionType.defaultTransition,
    CustomTransition? customTransition,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(routerName,
            duration: duration,
            module: module,
            customTransition: customTransition,
            guards: guards,
            transition: transition);
}
