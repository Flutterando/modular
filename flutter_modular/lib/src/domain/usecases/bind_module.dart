import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/module_service.dart';

abstract class BindModule {
  Result<Unit, ModularError> call(Module context);
}

class BindModuleImpl implements BindModule {
  final ModuleService moduleService;

  BindModuleImpl(this.moduleService);

  @override
  Result<Unit, ModularError> call(Module binds) {
    return moduleService.bind(binds);
  }
}
