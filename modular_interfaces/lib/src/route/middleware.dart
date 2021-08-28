import 'dart:async';

import 'modular_route.dart';

abstract class Middleware<T> {
  FutureOr<ModularRoute?> pre(ModularRoute route);
  FutureOr<ModularRoute?> pos(ModularRoute route, T data);
}
