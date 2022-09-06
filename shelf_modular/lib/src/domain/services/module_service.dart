import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Manages the module service
abstract class ModuleService {
  ///Start the module
  Either<ModularError, Unit> start(RouteContext module);
  ///Closes the Module
  Either<ModularError, Unit> finish();
  ///Checks if module is alive, returning true or false
  Future<Either<ModularError, bool>> isModuleReady<M extends Module>();
}
