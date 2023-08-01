import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/module_service.dart';

abstract class FinishModule {
  Result<Unit, ModularError> call();
}

class FinishModuleImpl implements FinishModule {
  final ModuleService moduleService;

  FinishModuleImpl(this.moduleService);

  @override
  Result<Unit, ModularError> call() {
    return moduleService.finish();
  }
}
