import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Item detail — still inside the shell'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.pop(), // pops the outlet's sub-stack
            child: const Text('Back to feed'),
          ),
        ],
      ),
    );
  }
}
