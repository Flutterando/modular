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
  B get<B>([Map<String, dynamic> params]) {
    params ??= {};
    if (tag == null) {
      return Modular.get<B>(params: params);
    } else {
      return Modular.get<B>(module: tag, params: params);
    }
  }

  ModularArguments get args {
    return Modular.args;
  }

  dispose<B>() {
    if (T.runtimeType.toString() == 'dynamic') {
      return Modular.dispose<B>();
    } else {
      return Modular.dispose<B>(tag);
    }
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
      Modular.get<S>(module: T.toString(), params: params);

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
