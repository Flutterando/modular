import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Implements [RouteService]
///Manage the avaiable route services such as [getRoute], [getArguments],
///[reportPush] and [reassemble]
class RouteServiceImpl implements RouteService {
  ///Instantiate a [tracker]

  final Tracker tracker;

  ///[RouteServiceImpl] constructor, receives a [tracker]
  RouteServiceImpl(this.tracker);

  @override
  Future<Either<ModularError, ModularRoute>> getRoute(
    RouteParmsDTO params,
  ) async {
    final route = await tracker.findRoute(
      params.url,
      data: params.arguments,
      schema: params.schema,
    );
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
