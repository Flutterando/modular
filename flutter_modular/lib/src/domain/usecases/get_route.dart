import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../dtos/route_dto.dart';
import '../services/route_service.dart';

abstract class GetRoute {
  AsyncResult<ModularRoute, ModularError> call(RouteParmsDTO params);
}

class GetRouteImpl implements GetRoute {
  final RouteService service;

  GetRouteImpl(this.service);

  @override
  AsyncResult<ModularRoute, ModularError> call(RouteParmsDTO params) {
    return service.getRoute(params);
  }
}
