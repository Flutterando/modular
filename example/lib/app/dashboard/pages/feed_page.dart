import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Feed view'),
          const SizedBox(height: 12),
          // Pushes INSIDE the outlet → item over feed, shell still mounted.
          // RELATIVE route: from `/dashboard`, `./item` resolves to
          // `/dashboard/item` — no need to repeat the shell prefix.
          FilledButton(
            onPressed: () => context.pushNamed('./item'),
            child: const Text('Open an item'),
          ),
        ],
      ),
    );
  }
}
