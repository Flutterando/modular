import 'package:modular_core/modular_core.dart';

import '../../shared/either.dart';
import '../services/route_service.dart';

///Reassemble the route
abstract class ReassembleTracker {
  ///Calls the method responsible for reassembling the route
  Either<ModularError, Unit> call();
}

///[ReassembleTracker] implementation
///Implements the method [call], returning the service resposible
///for reassembling the route
class ReassembleTrackerImpl implements ReassembleTracker {
  ///Instantiate a [service]
  final RouteService service;

  ///[ReassembleTrackerImpl] contructor, receives a [service]

  ReassembleTrackerImpl(this.service);

  @override
  Either<ModularError, Unit> call() {
    return service.reassemble();
  }
}
