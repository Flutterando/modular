import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';

abstract class GetArguments {
  ResultDart<ModularArguments, ModularError> call();
}

class GetArgumentsImpl implements GetArguments {
  final RouteService service;

  GetArgumentsImpl(this.service);

  @override
  ResultDart<ModularArguments, ModularError> call() {
    return service.getArguments();
  }
}
