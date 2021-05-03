import '../core/models/bind.dart';

import '../core/models/modular_arguments.dart';
import 'modular_base.dart';

class Inject<T> {
  final List<Type>? typesInRequest;
  final List<Bind>? overrideBinds;

  const Inject({this.typesInRequest, this.overrideBinds = const []});

  B call<B extends Object>([Bind<B>? bind]) => get<B>(bind);

  B get<B extends Object>([Bind<B>? bind]) {
    if (bind == null) {
      return Modular.get<B>(typesInRequestList: typesInRequest);
    } else {
      final candidateId = overrideBinds?.indexWhere((element) => element.runtimeType == bind.runtimeType) ?? -1;
      if (candidateId == -1) {
        return bind.inject(this);
      } else {
        return overrideBinds![candidateId].inject(this) as B;
      }
    }
  }

  ModularArguments? get args => Modular.args;

  bool dispose<B extends Object>() {
    return Modular.dispose<B>();
  }
}
