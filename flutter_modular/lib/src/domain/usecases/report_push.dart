import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/route_service.dart';

abstract class ReportPush {
  Result<Unit, ModularError> call(ModularRoute route);
}

class ReportPushImpl implements ReportPush {
  final RouteService service;

  ReportPushImpl(this.service);

  @override
  Result<Unit, ModularError> call(ModularRoute route) {
    return service.reportPush(route);
  }
}
