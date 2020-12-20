import '../core/models/modular_arguments.dart';
import 'modular_base.dart';

class Inject<T> {
  ///!!!!NOT RECOMMENDED USE!!!!
  ///Bind has access to the arguments coming from the routes.
  ///If you need specific access, do it through functions.
  @deprecated
  Map<String, dynamic>? params = {};
  final List<Type> typesInRequest;

  Inject({this.params, this.typesInRequest = const []});

  B? call<B extends Object>({Map<String, dynamic>? params, B? defaultValue}) => get<B>(params: params, defaultValue: defaultValue);

  B? get<B extends Object>({Map<String, dynamic>? params, B? defaultValue}) {
    params ??= {};
    return Modular.get<B>(
      params: params,
      typesInRequestList: typesInRequest,
      defaultValue: defaultValue,
    );
  }

  ModularArguments? get args => Modular.args;

  void dispose<B>() {
    if (T.runtimeType.toString() != 'dynamic') {
      Modular.dispose<B>();
    }
  }
}
