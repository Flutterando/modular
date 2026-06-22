/// An arbitrary object passed to a route via
/// `context.pushNamed('/args/editor', arguments: EditorArgs(...))` and read back
/// from `RouteState.arguments`.
class EditorArgs {
  const EditorArgs({required this.title, required this.initialText});

  final String title;
  final String initialText;
}
