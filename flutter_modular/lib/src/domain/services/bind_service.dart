import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class BindService {
  Result<T, ModularError> getBind<T extends Object>({String? tag});
  Result<bool, ModularError> disposeBind<T extends Object>({String? tag});
  Result<Unit, ModularError> replaceInstance<T>(T instance, [Type? module]);
}
