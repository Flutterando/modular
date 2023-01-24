library modular_core;

import 'package:auto_injector/auto_injector.dart';
import 'package:modular_core/src/module/main.dart';

export 'package:auto_injector/auto_injector.dart';

export 'src/di/disposable.dart';
export 'src/module/core_module.dart';
export 'src/module/main.dart';

/// Starting object to get routes and binds.
Tracker? _tracker;

Tracker get modularTracker {
  _tracker ??= Tracker(AutoInjector());
  return _tracker!;
}

///clean ModularTracker singleton
void cleanTracker() {
  _tracker?.finishApp();
  _tracker = null;
}
