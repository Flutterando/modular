import 'dart:async';

import 'modular_route.dart';

abstract class Middleware {
  FutureOr<ModularRoute?> call(ModularRoute route);
}
