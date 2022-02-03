import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../dtos/route_dto.dart';

abstract class RouteService {
  Future<Either<ModularError, ModularRoute>> getRoute(RouteParmsDTO params);
  Either<ModularError, ModularArguments> getArguments();
  Either<ModularError, Unit> setArguments(ModularArguments args);
  Either<ModularError, Unit> reportPop(ModularRoute route);
  Either<ModularError, Unit> reportPush(ModularRoute route);
  Either<ModularError, Unit> reassemble();
}
