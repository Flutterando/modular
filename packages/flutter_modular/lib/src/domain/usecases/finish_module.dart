import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../services/module_service.dart';

abstract class FinishModule {
  Either<ModularError, Unit> call();
}

class FinishModuleImpl implements FinishModule {
  final ModuleService moduleService;

  FinishModuleImpl(this.moduleService);

  @override
  Either<ModularError, Unit> call() {
    return moduleService.finish();
  }
}
