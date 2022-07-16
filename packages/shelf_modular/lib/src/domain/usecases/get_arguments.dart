import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';

abstract class GetArguments {
  Either<ModularError, ModularArguments> call();
}

class GetArgumentsImpl implements GetArguments {
  final RouteService service;

  GetArgumentsImpl(this.service);

  @override
  Either<ModularError, ModularArguments> call() {
    return service.getArguments();
  }
}
