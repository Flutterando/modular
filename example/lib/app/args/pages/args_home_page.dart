import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../models/editor_args.dart';

/// Launches the editor with an object [arguments] and awaits its popped result.
class ArgsHomePage extends StatefulWidget {
  const ArgsHomePage({super.key});

  @override
  State<ArgsHomePage> createState() => _ArgsHomePageState();
}

class _ArgsHomePageState extends State<ArgsHomePage> {
  String? _result;

  Future<void> _openEditor() async {
    // Pass an arbitrary object via `arguments`; await the value the editor pops.
    // Relative: from `/home/args` → `/home/args/editor`.
    final result = await context.pushNamed<String>(
      './editor',
      arguments: const EditorArgs(
        title: 'Edit greeting',
        initialText: 'Hello, Modular!',
      ),
    );
    if (!mounted) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arguments & pop result')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _result == null
                  ? 'No result yet — open the editor.'
                  : 'Editor returned: "$_result"',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Open editor'),
              onPressed: _openEditor,
            ),
          ],
        ),
      ),
    );
  }
}
