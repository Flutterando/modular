import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Implements [ModuleService]
//////Manage the avaiable module services such as [finish], [start]
///and [isModuleReady]
class ModuleServiceImpl extends ModuleService {
  ///Instantiate a [tracker]
  final Tracker tracker;

  ///[ModuleServiceImpl] constructor, receives a [tracker]

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
    return tracker.injector.isModuleReady<M>().then(right);
  }
}
