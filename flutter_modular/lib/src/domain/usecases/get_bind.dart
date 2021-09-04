import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/services/bind_service.dart';

abstract class GetBind {
  Either<ModularError, T> call<T extends Object>();
}

class GetBindImpl implements GetBind {
  final BindService bindService;

  GetBindImpl(this.bindService);

  @override
  Either<ModularError, T> call<T extends Object>() {
    return bindService.getBind<T>();
  }
}
