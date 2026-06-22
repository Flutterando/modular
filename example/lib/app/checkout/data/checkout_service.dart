import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// A FEATURE-scoped service. Because it is registered in the Checkout module's
/// own DI (`module(checkoutModule, at: '/checkout')`), it is bound when the
/// module's FIRST route is entered and disposed when its LAST route leaves the
/// stack — then re-created on re-entry. Watch the debug console for
/// "#N opened" / "#N closed".
class CheckoutService implements Disposable {
  CheckoutService() {
    opens++;
    debugPrint('CheckoutService #$id opened');
  }

  static int _seq = 0;

  /// Lifecycle counters (used by the example test).
  static int opens = 0;
  static int closes = 0;

  /// A per-instance id, so re-entry shows a NEW session number.
  final int id = ++_seq;

  @override
  void dispose() {
    closes++;
    debugPrint('CheckoutService #$id closed');
  }
}
