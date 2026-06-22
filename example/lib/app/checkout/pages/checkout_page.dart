import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../viewmodels/checkout_view_model.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CheckoutViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Checkout session #${vm.sessionId}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Leaving checkout disposes this session.'),
            const SizedBox(height: 24),
            FilledButton(
              // Relative: from `/home/checkout` → `/home/checkout/payment`.
              onPressed: () => context.pushNamed('./payment'),
              child: const Text('To payment'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Back home'),
            ),
          ],
        ),
      ),
    );
  }
}
