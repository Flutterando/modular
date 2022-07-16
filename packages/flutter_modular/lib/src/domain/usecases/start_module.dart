import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../services/module_service.dart';

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
