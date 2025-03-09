import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../dtos/route_dto.dart';

abstract class RouteService {
  AsyncResultDart<ModularRoute, ModularError> getRoute(RouteParmsDTO params);
  ResultDart<ModularArguments, ModularError> getArguments();
  ResultDart<Unit, ModularError> setArguments(ModularArguments args);
  ResultDart<Unit, ModularError> reportPop(ModularRoute route);
  ResultDart<Unit, ModularError> reportPush(ModularRoute route);
}
