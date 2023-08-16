import '../di/bind_context.dart';

import 'modular_key.dart';
import 'modular_route.dart';

abstract class RouteContext extends BindContext {
  /// Aggregates all [ModularRoute] type Objects to the context,
  List<ModularRoute> get routes;

  /// Used to return a route map at the start of the application.
  Map<ModularKey, ModularRoute> init();

  /// store all módules
  List<RouteContext> get modules;
}
