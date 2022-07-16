import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';

abstract class GetRoute {
  Future<Either<ModularError, ModularRoute>> call(RouteParmsDTO params);
}

class GetRouteImpl implements GetRoute {
  final RouteService service;

  GetRouteImpl(this.service);

  @override
  Future<Either<ModularError, ModularRoute>> call(RouteParmsDTO params) {
    return service.getRoute(params);
  }
}
