import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';

abstract class IsModuleReady {
  Future<Either<ModularError, bool>> call<T extends Module>();
}

class IsModuleReadyImpl implements IsModuleReady {
  final ModuleService moduleService;

  IsModuleReadyImpl(this.moduleService);

  @override
  Future<Either<ModularError, bool>> call<T extends Module>() {
    return moduleService.isModuleReady<T>();
  }
}
