import 'package:flutter/widgets.dart';

import 'scoped.dart';

/// Rebuilds ONLY its [builder] when [T] notifies — scopes the rebuild to a
/// sub-widget instead of the whole page (the granular alternative to `watch`).
class Consumer<T extends Listenable> extends StatefulWidget {
  const Consumer({required this.builder, this.child, super.key});

  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  State<Consumer<T>> createState() => _ConsumerState<T>();
}

class _ConsumerState<T extends Listenable> extends State<Consumer<T>> {
  T? _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final value = context.read<T>();
    if (!identical(value, _value)) {
      _value?.removeListener(_onChange);
      _value = value;
      _value!.addListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _value?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value!, widget.child);
}

/// Rebuilds its [builder] only when the SELECTED value [R] changes — surgical
/// reactivity over a [Listenable] view model.
class Selector<T extends Listenable, R> extends StatefulWidget {
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

class _SelectorState<T extends Listenable, R> extends State<Selector<T, R>> {
  T? _source;
  late R _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final source = context.read<T>();
    if (!identical(source, _source)) {
      _source?.removeListener(_onChange);
      _source = source;
      _source!.addListener(_onChange);
      _selected = widget.selector(context, _source!);
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
    _source?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _selected, widget.child);
}
