import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

abstract class BindService {
  ResultDart<T, ModularError> getBind<T extends Object>();
  ResultDart<bool, ModularError> disposeBind<T extends Object>();
}
