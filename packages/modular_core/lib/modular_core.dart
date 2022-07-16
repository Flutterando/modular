library modular_core;

import 'package:modular_core/src/di/injector.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

import 'src/route/tracker.dart' as t;

export 'src/di/async_bind.dart';
export 'src/di/resolvers.dart';
export 'src/di/injector.dart';
export 'src/di/disposable.dart';
export 'src/di/bind_context.dart';
export 'src/di/reassemble_mixin.dart';
export 'src/route/modular_route.dart';
export 'src/route/route_context.dart';
export 'package:modular_interfaces/modular_interfaces.dart';
export 'src/route/tracker.dart';

/// Starting object to get routes and binds.
Tracker? _tracker;

Tracker get modularTracker {
  _tracker ??= t.TrackerImpl(InjectorImpl());
  return _tracker!;
}

///clean ModularTracker singleton
void cleanTracker() {
  _tracker?.finishApp();
  _tracker = null;
}
