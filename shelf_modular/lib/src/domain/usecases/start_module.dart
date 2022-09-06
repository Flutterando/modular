import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Start the module
abstract class StartModule {
  ///Calls the method responsible for starting the module
  Either<ModularError, Unit> call(RouteContext context);
}

///[StartModule] implementation
///Implements the method [call], returning the service resposible
///for starting the module
class StartModuleImpl implements StartModule {
  ///Instantiate a [moduleService]

  final ModuleService moduleService;

  ///[StartModuleImpl] contructor, receives a [moduleService]

  StartModuleImpl(this.moduleService);

  @override
  Either<ModularError, Unit> call(RouteContext context) {
    return moduleService.start(context);
  }
}
