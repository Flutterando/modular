import 'package:flutter/material.dart';

class SecretPage extends StatelessWidget {
  const SecretPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secret')),
      body: const Center(child: Text('🔓 Secret area unlocked')),
    );
  }
}
