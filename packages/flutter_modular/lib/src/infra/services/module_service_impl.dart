import 'package:modular_core/modular_core.dart';

import '../../domain/services/module_service.dart';
import '../../presenter/models/module.dart';
import '../../shared/either.dart';

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
    var res = tracker.injector
        .isModuleReady<M>()
        .then((value) => right<ModularError, bool>(value));
    return res;
  }

  @override
  Either<ModularError, Unit> bind(BindContext module) {
    tracker.injector.addBindContext(module);
    return right(unit);
  }

  @override
  Either<ModularError, Unit> unbind<T extends BindContext>({Type? type}) {
    tracker.injector.removeBindContext<T>(type: type);
    return right(unit);
  }
}
