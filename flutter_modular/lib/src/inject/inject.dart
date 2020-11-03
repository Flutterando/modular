import '../../flutter_modular.dart';

import '../modular_base.dart';

class Inject<T> {
  ///!!!!NOT RECOMMENDED USE!!!!
  ///Bind has access to the arguments coming from the routes.
  ///If you need specific access, do it through functions.
  @deprecated
  Map<String, dynamic> params = {};
  final List<Type> typesInRequest;

  Inject({this.params, this.typesInRequest});

  B call<B>({Map<String, dynamic> params, B defaultValue}) =>
      get<B>(params: params, defaultValue: defaultValue);

  /// get injected dependency
  B get<B>({Map<String, dynamic> params, B defaultValue}) {
    params ??= {};
    return Modular.get<B>(
      params: params,
      typesInRequest: typesInRequest,
      defaultValue: defaultValue,
    );
  }

  void dispose<B>() {
    Modular.dispose<B>();
  }
}

mixin InjectMixinBase<T> {
  final Inject<T> _inject = Inject<T>();

  S get<S>() => _inject.get<S>();
}
