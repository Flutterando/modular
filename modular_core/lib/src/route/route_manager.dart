part of '../../modular_core.dart';

class RouteManager {
  final List<ModularRoute> _routes = [];

  @visibleForTesting
  List<ModularRoute> get allRoutes => List.unmodifiable(_routes);

  void add(ModularRoute route) {
    _routes.add(route);
  }
}
