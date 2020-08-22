import 'package:flutter/widgets.dart';
import '../../flutter_modular.dart';

import '../modular_base.dart';

class Inject<T> {
  ///!!!!NOT RECOMMENDED USE!!!!
  ///Bind has access to the arguments coming from the routes.
  ///If you need specific access, do it through functions.
  @deprecated
  Map<String, dynamic> params = {};
  final String tag;
  final List<Type> typesInRequest;

  Inject({this.params, this.tag, this.typesInRequest});

  factory Inject.of() => Inject(tag: T.toString());

  B call<B>({Map<String, dynamic> params, B defaultValue}) =>
      get<B>(params: params, defaultValue: defaultValue);

  /// get injected dependency
  B get<B>({Map<String, dynamic> params, B defaultValue}) {
    params ??= {};
    if (tag == null) {
      return Modular.get<B>(
        params: params,
        typesInRequest: typesInRequest,
        defaultValue: defaultValue,
      );
    } else {
      return Modular.get<B>(
        module: tag,
        params: params,
        typesInRequest: typesInRequest,
        defaultValue: defaultValue,
      );
    }
  }

  ModularArguments get args => Modular.args;

  /// get current module link
  RouteLink get link => Modular.link;

  void dispose<B>() {
    if (T.runtimeType.toString() == 'dynamic') {
      Modular.dispose<B>();
    } else {
      Modular.dispose<B>(tag);
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
