import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class Consumer<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T value) builder;
  final bool Function(T oldValue, T newValue) distinct;

  Consumer({
    Key key,
    @required this.builder,
    this.distinct,
  }) : super(key: key);

  @override
  _ConsumerState<T> createState() => _ConsumerState<T>();
}

class _ConsumerState<T extends ChangeNotifier> extends State<Consumer<T>> {
  T value;

  void listener() {
    T newValue = Modular.get<T>();
    if (widget.distinct == null || widget.distinct(value, newValue)) {
      setState(() => value = newValue);
    }
  }

  @override
  void initState() {
    super.initState();
    value = Modular.get<T>();
    value.addListener(listener);
  }

  @override
  void dispose() {
    value.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value);
  }
}
