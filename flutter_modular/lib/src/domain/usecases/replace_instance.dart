import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/bind_service.dart';

abstract class ReplaceInstance {
  ResultDart<Unit, ModularError> call<T>(T instance, [String? key]);
}

class ReplaceInstanceImpl implements ReplaceInstance {
  final BindService bindService;

  ReplaceInstanceImpl(this.bindService);

  @override
  ResultDart<Unit, ModularError> call<T>(T instance, [String? key]) {
    return bindService.replaceInstance<T>(instance, key);
  }
}
