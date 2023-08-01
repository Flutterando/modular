import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../../domain/dtos/route_dto.dart';
import '../../domain/errors/errors.dart';
import '../../domain/services/route_service.dart';

class RouteServiceImpl implements RouteService {
  final Tracker tracker;

  RouteServiceImpl(this.tracker);

  @override
  AsyncResult<ModularRoute, ModularError> getRoute(RouteParmsDTO params) async {
    final route = await tracker.findRoute(
      params.url,
      data: params.arguments,
      schema: params.schema,
    );
    if (route != null) {
      return Success(route);
    } else {
      return Failure(RouteNotFoundException('Route (${params.url}) not found'));
    }
  }

  @override
  Result<ModularArguments, ModularError> getArguments() {
    return Success(tracker.arguments);
  }

  @override
  Result<Unit, ModularError> reportPop(ModularRoute route) {
    tracker.reportPopRoute(route);
    return const Success(unit);
  }

  @override
  Result<Unit, ModularError> setArguments(ModularArguments args) {
    tracker.setArguments(args);
    return const Success(unit);
  }

  @override
  Result<Unit, ModularError> reportPush(ModularRoute route) {
    tracker.reportPushRoute(route);
    return const Success(unit);
  }
}
