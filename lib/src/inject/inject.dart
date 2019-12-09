import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../modular_base.dart';

class Inject<T> {
  Map<String, dynamic> params = {};
  final String tag;

  Inject({this.params, this.tag = "global=="});

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

mixin InjectMixin<T> {

  final Inject<T> _inject = Inject<T>.of();

  S get<S>() {
    return _inject.get<S>();
  }

  Widget consumer<S extends ChangeNotifier>({Widget Function(BuildContext context, S value) builder, bool Function(S oldValue, S newValue) distinct}) {
    return ConsumerWidget<S>(builder: builder, distinct: distinct, inject: _inject,);
  }

}
