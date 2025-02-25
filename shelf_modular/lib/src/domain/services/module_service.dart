import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class ModuleService {
  ResultDart<Unit, ModularError> start(Module module);
  ResultDart<Unit, ModularError> finish();
}
