import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/services/module_service.dart';

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
