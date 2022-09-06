import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Manages the Route
abstract class RouteService {
  ///Gets the route
  Future<Either<ModularError, ModularRoute>> getRoute(RouteParmsDTO params);
  ///Get the arguments of the route
  Either<ModularError, ModularArguments> getArguments();
  ///Push the [route]
  Either<ModularError, Unit> reportPush(ModularRoute route);
  ///Reassemble the route
  Either<ModularError, Unit> reassemble();
}
