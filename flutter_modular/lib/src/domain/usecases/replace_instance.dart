import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/bind_service.dart';

abstract class ReplaceInstance {
  Result<Unit, ModularError> call<T>(T instance);
}

class ReplaceInstanceImpl implements ReplaceInstance {
  final BindService bindService;

  ReplaceInstanceImpl(this.bindService);

  @override
  Result<Unit, ModularError> call<T>(T instance) {
    return bindService.replaceInstance<T>(instance);
  }
}
