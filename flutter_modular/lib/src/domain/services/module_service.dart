import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/shared/either.dart';

abstract class ModuleService {
  Either<ModularError, Unit> start(RouteContext module);
  Either<ModularError, Unit> bind(BindContext module);
  Either<ModularError, Unit> unbind<T extends BindContext>();
  Either<ModularError, Unit> finish();
  Future<Either<ModularError, bool>> isModuleReady<M extends Module>();
}
