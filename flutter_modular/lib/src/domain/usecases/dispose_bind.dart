import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/bind_service.dart';

abstract class DisposeBind {
  ResultDart<bool, ModularError> call<T extends Object>([String? key]);
}

class DisposeBindImpl implements DisposeBind {
  final BindService bindService;

  DisposeBindImpl(this.bindService);

  @override
  ResultDart<bool, ModularError> call<T extends Object>([String? key]) {
    return bindService.disposeBind<T>(key);
  }
}
