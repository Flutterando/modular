import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/route_service.dart';

abstract class GetArguments {
  Result<ModularArguments, ModularError> call();
}

class GetArgumentsImpl implements GetArguments {
  final RouteService service;

  GetArgumentsImpl(this.service);

  @override
  Result<ModularArguments, ModularError> call() {
    return service.getArguments();
  }
}
