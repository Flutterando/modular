import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/services/module_service.dart';

class ModuleServiceImpl extends ModuleService {
  final Tracker tracker;

  ModuleServiceImpl(this.tracker);

  @override
  Either<ModularError, Unit> finish() {
    tracker.finishApp();
    return right(unit);
  }

  @override
  Either<ModularError, Unit> start(RouteContext module) {
    tracker.runApp(module);
    return right(unit);
  }

  @override
  Future<Either<ModularError, bool>> isModuleReady<M extends Module>() {
    return tracker.injector.isModuleReady().then((value) => right(value));
  }

  @override
  Either<ModularError, Unit> bind(BindContext module) {
    tracker.injector.bindContext(module);
    return right(unit);
  }

  @override
  Either<ModularError, Unit> unbind<T extends BindContext>() {
    tracker.injector.removeBindContext<T>();
    return right(unit);
  }
}
