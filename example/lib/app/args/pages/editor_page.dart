import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../models/editor_args.dart';

/// Receives an [EditorArgs] (via `RouteState.arguments`) and returns the edited
/// text through `context.pop(result)`.
class EditorPage extends StatefulWidget {
  const EditorPage({required this.args, super.key});

  final EditorArgs args;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.args.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.args.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Greeting'),
            ),
            const Spacer(),
            Row(
              children: [
                TextButton(
                  onPressed: () => context.pop(), // returns null
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton(
                  // returns the edited value to the awaiting `pushNamed`
                  onPressed: () => context.pop(_controller.text),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
