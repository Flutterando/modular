import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/services/module_service.dart';

abstract class UnbindModule {
  Either<ModularError, Unit> call<T extends BindContext>({Type? type});
}

class UnbindModuleImpl implements UnbindModule {
  final ModuleService moduleService;

  UnbindModuleImpl(this.moduleService);

  @override
  Either<ModularError, Unit> call<T extends BindContext>({Type? type}) {
    return moduleService.unbind<T>(type: type);
  }
}
