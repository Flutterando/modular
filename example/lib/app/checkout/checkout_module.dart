import 'package:flutter_modular/flutter_modular.dart';

import 'data/checkout_service.dart';
import 'pages/checkout_page.dart';
import 'pages/payment_page.dart';
import 'viewmodels/checkout_view_model.dart';

/// ---------------------------------------------------------------------------
/// CHECKOUT FEATURE — demonstrates the per-module DI LIFECYCLE.
///
/// [CheckoutService] is registered in THIS module's DI, so it is feature-scoped:
/// bound when the first checkout route enters the stack and disposed when the
/// LAST one leaves (recreated on re-entry). The summary and payment routes
/// share the single instance while either is on screen.
///
/// Contrast with `core_module` (the ProductRepository), which is included
/// without `at` → root-owned → never disposed (the app-wide SSoT).
/// ---------------------------------------------------------------------------
final checkoutModule = createModule(
  path: '/checkout',
  register: (c) {
    c
      ..addSingleton<CheckoutService>(CheckoutService.new)
      ..route(
        '/',
        provide: (s) =>
            s.addChangeNotifier<CheckoutViewModel>(CheckoutViewModel.new),
        child: (ctx, state) => const CheckoutPage(),
      )
      ..route('/payment', child: (ctx, state) => const PaymentPage());
  },
);
