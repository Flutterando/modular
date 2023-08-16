import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/bind_service.dart';

abstract class GetBind {
  Result<T, ModularError> call<T extends Object>({String? tag});
}

class GetBindImpl implements GetBind {
  final BindService bindService;

  GetBindImpl(this.bindService);

  @override
  Result<T, ModularError> call<T extends Object>({String? tag}) {
    return bindService.getBind<T>(tag: tag);
  }
}
