import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/bind_service.dart';

abstract class GetBind {
  ResultDart<T, ModularError> call<T extends Object>([String? key]);
}

class GetBindImpl implements GetBind {
  final BindService bindService;

  GetBindImpl(this.bindService);

  @override
  ResultDart<T, ModularError> call<T extends Object>([String? key]) {
    return bindService.getBind<T>(key);
  }
}
