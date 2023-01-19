import '../../presenter/models/module.dart';
import 'package:modular_core/modular_core.dart';
import '../../../flutter_modular.dart';
import '../../shared/either.dart';

abstract class ModuleService {
  Either<ModularError, Unit> start(RouteContext module);
  Either<ModularError, Unit> bind(BindContext module);
  Either<ModularError, Unit> unbind<T extends BindContext>({Type? type});
  Either<ModularError, Unit> finish();
  Future<Either<ModularError, bool>> isModuleReady<M extends Module>();
}
