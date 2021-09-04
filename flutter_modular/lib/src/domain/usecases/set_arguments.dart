import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/services/route_service.dart';

abstract class SetArguments {
  Either<ModularError, Unit> call(ModularArguments args);
}

class SetArgumentsImpl implements SetArguments {
  final RouteService service;

  SetArgumentsImpl(this.service);

  @override
  Either<ModularError, Unit> call(ModularArguments args) {
    return service.setArguments(args);
  }
}
