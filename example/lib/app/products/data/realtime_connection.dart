import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// `add` demo: a NON-reactive resource opened while the detail page is alive and
/// closed on exit. Registered with `add` and cleaned up because it implements
/// [Disposable]. It is injected into the detail VM (the same page-scoped
/// instance), showing reactivity and lifecycle are independent.
class RealtimeConnection implements Disposable {
  bool isOpen = true;

  @override
  void dispose() {
    isOpen = false;
    debugPrint('RealtimeConnection closed');
  }
}
