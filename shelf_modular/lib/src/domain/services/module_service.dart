import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';

abstract class ModuleService {
  Either<ModularError, Unit> start(RouteContext module);
  Either<ModularError, Unit> finish();
  Future<Either<ModularError, bool>> isModuleReady<M extends Module>();
}
