import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/services/route_service.dart';

abstract class ReassembleTracker {
  Either<ModularError, Unit> call();
}

class ReassembleTrackerImpl implements ReassembleTracker {
  final RouteService service;

  ReassembleTrackerImpl(this.service);

  @override
  Either<ModularError, Unit> call() {
    return service.reassemble();
  }
}
