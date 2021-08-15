library modular_core;

import 'package:meta/meta.dart';
import 'src/route/tracker.dart' as t;

import 'src/route/modular_route.dart';
import 'src/route/route_context.dart';
import 'src/di/bind.dart';

export 'src/di/bind.dart';
export 'src/di/resolvers.dart';
export 'src/route/modular_route.dart';

abstract class Module extends RouteContext {
  @visibleForOverriding
  @override
  List<Module> get imports => const [];

  @visibleForOverriding
  @override
  List<Bind> get binds => const [];

  @override
  List<ModularRoute> get routes => const [];
}

final Tracker = t.Tracker();
