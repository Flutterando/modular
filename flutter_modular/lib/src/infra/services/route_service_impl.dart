import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../../domain/dtos/route_dto.dart';
import '../../domain/errors/errors.dart';
import '../../domain/services/route_service.dart';

class RouteServiceImpl implements RouteService {
  final Tracker tracker;

  RouteServiceImpl(this.tracker);

  @override
  Future<Either<ModularError, ModularRoute>> getRoute(
      RouteParmsDTO params) async {
    var route = await tracker.findRoute(params.url,
        data: params.arguments, schema: params.schema);
    if (route != null) {
      return right(route);
    } else {
      return left(RouteNotFoundException('Route (${params.url}) not found'));
    }
  }

  @override
  Either<ModularError, ModularArguments> getArguments() {
    return right(tracker.arguments);
  }

  @override
  Either<ModularError, Unit> reportPop(ModularRoute route) {
    tracker.reportPopRoute(route);
    return right(unit);
  }

  @override
  Either<ModularError, Unit> setArguments(ModularArguments args) {
    tracker.setArguments(args);
    return right(unit);
  }

  @override
  Either<ModularError, Unit> reportPush(ModularRoute route) {
    tracker.reportPushRoute(route);
    return right(unit);
  }

  @override
  Either<ModularError, Unit> reassemble() {
    tracker.reassemble();
    return right(unit);
  }
}
