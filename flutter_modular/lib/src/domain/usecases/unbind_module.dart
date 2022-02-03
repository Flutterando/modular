import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../services/module_service.dart';

abstract class UnbindModule {
  Either<ModularError, Unit> call<T extends BindContext>();
}

class UnbindModuleImpl implements UnbindModule {
  final ModuleService moduleService;

  UnbindModuleImpl(this.moduleService);

  @override
  Either<ModularError, Unit> call<T extends BindContext>() {
    return moduleService.unbind<T>();
  }
}
