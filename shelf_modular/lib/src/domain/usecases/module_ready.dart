import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Checks if the module is ready
abstract class IsModuleReady {
  ///Calls the method responsible for checking the status of the module
  Future<Either<ModularError, bool>> call<T extends Module>();
}

///[IsModuleReady] implementation
///Implements the method [call], returning the service resposible
///for checking the status of the module
class IsModuleReadyImpl implements IsModuleReady {
  ///Instantiate a [moduleService]

  final ModuleService moduleService;

  ///[IsModuleReadyImpl] contructor, receives a [moduleService]

  IsModuleReadyImpl(this.moduleService);

  @override
  Future<Either<ModularError, bool>> call<T extends Module>() {
    return moduleService.isModuleReady<T>();
  }
}
