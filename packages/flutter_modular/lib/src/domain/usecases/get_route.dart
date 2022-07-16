import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../dtos/route_dto.dart';
import '../services/route_service.dart';

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
