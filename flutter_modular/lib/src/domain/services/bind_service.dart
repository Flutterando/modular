import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class BindService {
  ResultDart<T, ModularError> getBind<T extends Object>([String? key]);
  ResultDart<bool, ModularError> disposeBind<T extends Object>([String? key]);
  ResultDart<Unit, ModularError> replaceInstance<T>(T instance, [String? key]);
}
