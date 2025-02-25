import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';

class ModuleServiceImpl extends ModuleService {
  final Tracker tracker;

  ModuleServiceImpl(this.tracker);

  @override
  ResultDart<Unit, ModularError> finish() {
    tracker.finishApp();
    return const Success(unit);
  }

  @override
  ResultDart<Unit, ModularError> start(Module module) {
    tracker.runApp(module);
    return const Success(unit);
  }
}
