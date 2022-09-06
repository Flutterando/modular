import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Release the binds in scope
abstract class ReleaseScopedBinds {
  ///Calls the method responsible for releasing the binds in scope
  Either<ModularError, Unit> call<T extends Object>();
}

///[ReleaseScopedBinds] implementation
///Implements the method [call], returning the service resposible
///for releasing the binds in scope
class ReleaseScopedBindsImpl implements ReleaseScopedBinds {
  ///Instantiate a [bindService]

  final BindService bindService;

  ///[ReleaseScopedBindsImpl] contructor, receives a [bindService]

  ReleaseScopedBindsImpl(this.bindService);

  @override
  Either<ModularError, Unit> call<T extends Object>() {
    return bindService.releaseScopedBinds();
  }
}
