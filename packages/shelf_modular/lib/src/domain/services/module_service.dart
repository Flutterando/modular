import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/shared/either.dart';

abstract class ModuleService {
  Either<ModularError, Unit> start(RouteContext module);
  Either<ModularError, Unit> finish();
  Future<Either<ModularError, bool>> isModuleReady<M extends Module>();
}
