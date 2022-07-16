import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../services/route_service.dart';

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
