import 'package:flutter/foundation.dart';

import '../data/checkout_service.dart';

/// Page-scoped VM that INJECTS the feature-scoped [CheckoutService] — two
/// lifecycles at once: the VM dies with its page, the service with the module.
class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel(this._service);

  final CheckoutService _service;

  int get sessionId => _service.id;
}
