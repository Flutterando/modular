import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';

abstract class RouteService {
  Future<Either<ModularError, ModularRoute>> getRoute(RouteParmsDTO params);
  Either<ModularError, ModularArguments> getArguments();
  Either<ModularError, Unit> reportPush(ModularRoute route);
}
