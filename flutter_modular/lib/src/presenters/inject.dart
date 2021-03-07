import '../core/models/bind.dart';

import '../core/models/modular_arguments.dart';
import 'modular_base.dart';

class Inject<T> {
  final List<Type>? typesInRequest;

  Inject({this.typesInRequest});

  B call<B extends Object>([Bind<B>? bind]) => get<B>(bind);

  B get<B extends Object>([Bind<B>? bind]) {
    if (bind == null) {
      return Modular.get<B>(typesInRequestList: typesInRequest);
    } else {
      return bind.inject(this);
    }
  }

  ModularArguments? get args => Modular.args;

  bool dispose<B extends Object>() {
    return Modular.dispose<B>();
  }
}
