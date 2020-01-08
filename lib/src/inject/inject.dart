import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../modular_base.dart';

class Inject<T> {
  Map<String, dynamic> params = {};
  final String tag;

  Inject({
    this.params,
    this.tag = "global==",
  });

  factory Inject.of() => Inject(tag: T.toString());

  ///get injected dependency
  T get<T>([Map<String, dynamic> params]) {
    params ??= {};
    return Modular.getInjectableObject<T>(tag, params: params);
  }

  dispose<T>() {
    return Modular.removeInjectableObject<T>(tag);
  }
}

@Deprecated("Use InjectWidgetMixin instead")
mixin InjectMixin<T> {
  final Inject<T> _inject = Inject<T>.of();

  S get<S>() {
    return _inject.get<S>();
  }

  Widget consumer<S extends ChangeNotifier>({
    Widget Function(BuildContext context, S value) builder,
    bool Function(S oldValue, S newValue) distinct,
  }) {
    return ConsumerWidget<S>(
      builder: builder,
      distinct: distinct,
      inject: _inject,
    );
  }
}

mixin InjectMixinBase<T> {
  final Inject<T> _inject = Inject<T>.of();

  S get<S>() => _inject.get<S>();

  Widget consumer<S extends ChangeNotifier>({
    Widget Function(BuildContext context, S value) builder,
    bool Function(S oldValue, S newValue) distinct,
  }) {
    return ConsumerWidget(
      builder: builder,
      distinct: distinct,
      inject: _inject,
    );
  }
}

/// A mixin that must be used only with classes that extends a [Widget]
/// [T] the module to be injected on the widget.
mixin InjectWidgetMixin<T extends ChildModule> on Widget
    implements InjectMixinBase<T> {
  final Inject<T> _inject = Inject<T>.of();

  S get<S>() => _inject.get<S>();

  Widget consumer<S extends ChangeNotifier>({
    Widget Function(BuildContext context, S value) builder,
    bool Function(S oldValue, S newValue) distinct,
  }) {
    return ConsumerWidget(
      builder: builder,
      distinct: distinct,
      inject: _inject,
    );
  }
}
