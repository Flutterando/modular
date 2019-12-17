import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ConsumerWidget<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T value) builder;
  final Inject inject;
  final bool Function(T oldValue, T newValue) distinct;

  ConsumerWidget({Key key, @required this.builder, this.inject, this.distinct})
      : super(key: key);

  @override
  _ConsumerWidgetState<T> createState() => _ConsumerWidgetState<T>();
}

class _ConsumerWidgetState<T extends ChangeNotifier>
    extends State<ConsumerWidget<T>> {
  T value;

  Inject _inject;

  void listener() {
    T newValue = _inject.get<T>();
    if (widget.distinct == null || widget.distinct(value, newValue)) {
      setState(() {
        value = newValue;
      });
    }
  }

  @override
  void initState() {
    _inject = widget.inject ?? Inject();
    value = _inject.get<T>();
    value.addListener(listener);
    super.initState();
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
