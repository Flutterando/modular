import 'package:flutter/widgets.dart';

import 'scoped.dart';

/// Rebuilds ONLY its [builder] when [T]'s trigger notifies — scopes the rebuild
/// to a sub-widget instead of the whole page (the granular alternative to
/// `watch`). [T] is the page-scoped value (a `ChangeNotifier`, a bloc
/// registered via `addStreamable`, etc.); rebuilds are driven by its trigger.
class Consumer<T extends Object> extends StatefulWidget {
  const Consumer({required this.builder, this.child, super.key});

  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  State<Consumer<T>> createState() => _ConsumerState<T>();
}

class _ConsumerState<T extends Object> extends State<Consumer<T>> {
  late T _value;
  Listenable? _trigger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pair = context.scopedPair<T>();
    _value = pair.value;
    if (!identical(pair.trigger, _trigger)) {
      _trigger?.removeListener(_onChange);
      _trigger = pair.trigger;
      _trigger?.addListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _trigger?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, widget.child);
}

/// Rebuilds its [builder] only when the SELECTED value [R] changes — surgical
/// reactivity over a page-scoped value [T] (a view model, a bloc, etc.).
class Selector<T extends Object, R> extends StatefulWidget {
  const Selector({
    required this.selector,
    required this.builder,
    this.child,
    super.key,
  });

  final R Function(BuildContext context, T value) selector;
  final Widget Function(BuildContext context, R value, Widget? child) builder;
  final Widget? child;

  @override
  State<Selector<T, R>> createState() => _SelectorState<T, R>();
}

class _SelectorState<T extends Object, R> extends State<Selector<T, R>> {
  T? _source;
  Listenable? _trigger;
  late R _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pair = context.scopedPair<T>();
    if (!identical(pair.value, _source)) {
      _source = pair.value;
      _selected = widget.selector(context, _source!);
    }
    if (!identical(pair.trigger, _trigger)) {
      _trigger?.removeListener(_onChange);
      _trigger = pair.trigger;
      _trigger?.addListener(_onChange);
    }
  }

  void _onChange() {
    final next = widget.selector(context, _source!);
    if (next != _selected && mounted) {
      setState(() => _selected = next);
    }
  }

  @override
  void dispose() {
    _trigger?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _selected, widget.child);
}
