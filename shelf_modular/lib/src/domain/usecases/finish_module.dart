import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Finishes the module
abstract class FinishModule {
  ///Calls the method responsible for finishing the bind
  Either<ModularError, Unit> call();
}

///[FinishModule] implementation
///Implements the method [call], returning the service resposible
///for finishing the bind.
class FinishModuleImpl implements FinishModule {
  ///Instantiate a [moduleService]
  final ModuleService moduleService;

  ///[FinishModuleImpl] contructor, receives a [moduleService]

  FinishModuleImpl(this.moduleService);

  @override
  Either<ModularError, Unit> call() {
    return moduleService.finish();
  }
}
