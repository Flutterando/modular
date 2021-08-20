library modular_core;

import 'package:modular_core/src/di/injector.dart';

import 'src/route/tracker.dart' as t;

export 'src/di/async_bind.dart';
export 'src/di/resolvers.dart';
export 'src/di/injector.dart';
export 'src/di/disposable.dart';
export 'src/route/modular_route.dart';
export 'src/route/route_guard.dart';
export 'src/route/route_context.dart';
export 'package:modular_interfaces/modular_interfaces.dart';
export 'src/route/tracker.dart';

final ModularTracker = t.TrackerImpl(InjectorImpl());
