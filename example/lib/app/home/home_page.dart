import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// The landing page, mounted at `/home`. Its buttons use RELATIVE routes
/// (`./products`, `./settings`, …): from `/home` they resolve to
/// `/home/products`, `/home/settings`, … so the page never repeats its own
/// mount prefix. A leading `/` would make them absolute instead.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_modular v7')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A tiny store, modular.'),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.storefront),
              label: const Text('Browse products'),
              onPressed: () => context.pushNamed('./products'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
              onPressed: () => context.pushNamed('./settings'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Arguments & pop result'),
              onPressed: () => context.pushNamed('./args'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Checkout'),
              onPressed: () => context.pushNamed('./checkout'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.dashboard),
              label: const Text('Dashboard (RouterOutlet)'),
              onPressed: () => context.navigate('./dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
