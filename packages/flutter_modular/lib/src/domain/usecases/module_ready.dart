import '../../presenter/models/module.dart';
import 'package:modular_core/modular_core.dart';
import '../../../flutter_modular.dart';
import '../../shared/either.dart';
import '../services/module_service.dart';

abstract class IsModuleReady {
  Future<Either<ModularError, bool>> call<T extends Module>();
}

class IsModuleReadyImpl implements IsModuleReady {
  final ModuleService moduleService;

  IsModuleReadyImpl(this.moduleService);

  @override
  Future<Either<ModularError, bool>> call<T extends Module>() async {
    return await moduleService.isModuleReady<T>();
  }
}
