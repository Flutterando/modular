import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../services/route_service.dart';

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
