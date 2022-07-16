import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';

abstract class StartModule {
  Either<ModularError, Unit> call(RouteContext context);
}

class StartModuleImpl implements StartModule {
  final ModuleService moduleService;

  StartModuleImpl(this.moduleService);

  @override
  Either<ModularError, Unit> call(RouteContext context) {
    return moduleService.start(context);
  }
}
