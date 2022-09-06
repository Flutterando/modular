import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Get the route
abstract class GetRoute {
  ///Calls the method responsible for getting the bind
  Future<Either<ModularError, ModularRoute>> call(RouteParmsDTO params);
}

///[GetRoute] implementation
///Implements the method [call], returning the service resposible
///for getting the route
class GetRouteImpl implements GetRoute {
  ///Instantiate a [service]

  final RouteService service;

  ///[GetRouteImpl] contructor, receives a [service]

  GetRouteImpl(this.service);

  @override
  Future<Either<ModularError, ModularRoute>> call(RouteParmsDTO params) {
    return service.getRoute(params);
  }
}
