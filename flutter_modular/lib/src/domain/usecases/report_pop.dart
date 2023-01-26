import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/route_service.dart';

abstract class ReportPop {
  Result<Unit, ModularError> call(ModularRoute route);
}

class ReportPopImpl implements ReportPop {
  final RouteService service;

  ReportPopImpl(this.service);

  @override
  Result<Unit, ModularError> call(ModularRoute route) {
    return service.reportPop(route);
  }
}
