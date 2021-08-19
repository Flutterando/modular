import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/core/either.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';

abstract class RouteService {
  Future<Either<ModularError, ModularRoute>> getRoute(RouteParmsDTO params);
}
