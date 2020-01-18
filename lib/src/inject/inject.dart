import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../modular_base.dart';

class Inject<T> {
  Map<String, dynamic> params = {};
  final String tag;

  Inject({
    this.params,
    this.tag,
  });

  factory Inject.of() => Inject(tag: T.toString());

  ///get injected dependency
  T get<T>([Map<String, dynamic> params]) {
    params ??= {};
    if (tag == null) {
      return Modular.get<T>(params: params);
    } else {
      return Modular.getInjectableObject<T>(tag, params: params);
    }
  }

  dispose<T>() {
    return Modular.removeInjectableObject<T>(tag);
  }
}

mixin InjectMixinBase<T> {
  final Inject<T> _inject = Inject<T>.of();

  S get<S>() => _inject.get<S>();
}

/// A mixin that must be used only with classes that extends a [Widget]
/// [T] the module to be injected on the widget.
mixin InjectWidgetMixin<T extends ChildModule> on Widget
    implements InjectMixinBase<T> {
  final Inject<T> _inject = Inject<T>.of();

  S get<S>({Map<String, dynamic> params}) =>
      Modular.get<S>(module: T.runtimeType, params: params);

  Widget consumer<S extends ChangeNotifier>({
    Widget Function(BuildContext context, S value) builder,
    bool Function(S oldValue, S newValue) distinct,
  }) {
    return Consumer(
      builder: builder,
      distinct: distinct,
    );
  }
}
