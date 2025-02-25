import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';

abstract class FinishModule {
  ResultDart<Unit, ModularError> call();
}

class FinishModuleImpl implements FinishModule {
  final ModuleService moduleService;

  FinishModuleImpl(this.moduleService);

  @override
  ResultDart<Unit, ModularError> call() {
    return moduleService.finish();
  }
}
