import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../dtos/route_dto.dart';

abstract class RouteService {
  AsyncResult<ModularRoute, ModularError> getRoute(RouteParmsDTO params);
  Result<ModularArguments, ModularError> getArguments();
  Result<Unit, ModularError> setArguments(ModularArguments args);
  Result<Unit, ModularError> reportPop(ModularRoute route);
  Result<Unit, ModularError> reportPush(ModularRoute route);
}
