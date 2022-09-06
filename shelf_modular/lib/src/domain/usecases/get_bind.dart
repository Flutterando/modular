import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Get the bind
abstract class GetBind {
  ///Calls the method responsible for getting the bind
  Either<ModularError, T> call<T extends Object>();
}

///[GetBind] implementation
///Implements the method [call], returning the service resposible
///for getting the bind
class GetBindImpl implements GetBind {
  ///Instantiate a [bindService]

  final BindService bindService;

  ///[GetBindImpl] contructor, receives a [bindService]

  GetBindImpl(this.bindService);

  @override
  Either<ModularError, T> call<T extends Object>() {
    return bindService.getBind<T>();
  }
}
