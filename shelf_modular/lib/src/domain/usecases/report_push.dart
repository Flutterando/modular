import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Reports a route push
abstract class ReportPush {
  ///Calls the method responsible for reporting the route push
  Either<ModularError, Unit> call(ModularRoute route);
}

///[ReportPush] implementation
///Implements the method [call], returning the service resposible
///for reporting the route push
class ReportPushImpl implements ReportPush {
  ///Instantiate a [service]
  final RouteService service;

  ///[ReportPushImpl] contructor, receives a [service]
  ReportPushImpl(this.service);

  @override
  Either<ModularError, Unit> call(ModularRoute route) {
    return service.reportPush(route);
  }
}
