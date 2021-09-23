import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/services/route_service.dart';

abstract class ReportPop {
  Either<ModularError, Unit> call(ModularRoute route);
}

class ReportPopImpl implements ReportPop {
  final RouteService service;

  ReportPopImpl(this.service);

  @override
  Either<ModularError, Unit> call(ModularRoute route) {
    return service.reportPop(route);
  }
}
