import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';

abstract class RouteService {
  AsyncResultDart<ModularRoute, ModularError> getRoute(RouteParmsDTO params);
  ResultDart<ModularArguments, ModularError> getArguments();
  ResultDart<Unit, ModularError> reportPush(ModularRoute route);
}
