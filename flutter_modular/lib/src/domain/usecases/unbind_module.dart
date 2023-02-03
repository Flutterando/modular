import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../services/module_service.dart';

abstract class UnbindModule {
  Result<Unit, ModularError> call<T extends Module>({String? type});
}

class UnbindModuleImpl implements UnbindModule {
  final ModuleService moduleService;

  UnbindModuleImpl(this.moduleService);

  @override
  Result<Unit, ModularError> call<T extends Module>({String? type}) {
    return moduleService.unbind<T>(type: type);
  }
}
