import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/module_service.dart';

abstract class StartModule {
  Result<Unit, ModularError> call(Module context);
}

class StartModuleImpl implements StartModule {
  final ModuleService moduleService;

  StartModuleImpl(this.moduleService);

  @override
  Result<Unit, ModularError> call(Module context) {
    return moduleService.start(context);
  }
}
