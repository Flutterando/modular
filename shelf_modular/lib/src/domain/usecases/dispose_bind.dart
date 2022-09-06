import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Disposes the bind
abstract class DisposeBind {
///Calls the method responsible for disposing the bind
  Either<ModularError, bool> call<T extends Object>();
}

///[DisposeBind] implementation
///Implements the method [call], returning the service resposible
///for disposing the bind.
class DisposeBindImpl implements DisposeBind {
///Instantiate a [bindService]
  final BindService bindService;
///[DisposeBindImpl] contructor, receives a [BindService]
  DisposeBindImpl(this.bindService);

  @override
  Either<ModularError, bool> call<T extends Object>() {
    return bindService.disposeBind<T>();
  }
}
