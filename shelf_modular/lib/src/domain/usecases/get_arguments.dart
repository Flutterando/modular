import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Get the arguments of a route
abstract class GetArguments {
  ///Calls the method responsible for getting the arguments
  Either<ModularError, ModularArguments> call();
}

///[GetArguments] implementation
///Implements the method [call], returning the service resposible
///for getting the arguments.
class GetArgumentsImpl implements GetArguments {
  ///Instantiate a [RouteService]

  final RouteService service;

  ///[GetArgumentsImpl] contructor, receives a [service]

  GetArgumentsImpl(this.service);

  @override
  Either<ModularError, ModularArguments> call() {
    return service.getArguments();
  }
}
