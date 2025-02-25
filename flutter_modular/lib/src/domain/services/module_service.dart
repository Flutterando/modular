import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class ModuleService {
  ResultDart<Unit, ModularError> start(Module module);
  ResultDart<Unit, ModularError> bind(Module module, [String? tag]);
  ResultDart<Unit, ModularError> unbind<T extends Module>({String? type});
  ResultDart<Unit, ModularError> finish();
}
