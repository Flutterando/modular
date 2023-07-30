import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class ModuleService {
  Result<Unit, ModularError> start(Module module);
  Result<Unit, ModularError> finish();
}
