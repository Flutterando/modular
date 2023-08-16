part of '../../modular_core.dart';

/// Object that intercepts a route request.
abstract class Middleware<T> {
  /// Method called as soon as route is found and before settings.
  FutureOr<ModularRoute?> pre(ModularRoute route);

  /// Method called as soon as route is found and after settings.
  FutureOr<ModularRoute?> pos(ModularRoute route, T data);
}
