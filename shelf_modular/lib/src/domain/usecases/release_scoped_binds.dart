import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';

abstract class ReleaseScopedBinds {
  Either<ModularError, Unit> call<T extends Object>();
}

class ReleaseScopedBindsImpl implements ReleaseScopedBinds {
  final BindService bindService;

  ReleaseScopedBindsImpl(this.bindService);

  @override
  Either<ModularError, Unit> call<T extends Object>() {
    return bindService.releaseScopedBinds();
  }
}
