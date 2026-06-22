import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../data/checkout_service.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // `inject<T>()` resolves the SAME feature instance the summary VM uses —
    // the module is still active across both of its routes.
    final session = inject<CheckoutService>().id;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paying for session #$session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
