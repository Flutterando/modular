import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';

abstract class BindService {
  Either<ModularError, BindEntry<T>> getBind<T extends Object>();
  Either<ModularError, bool> disposeBind<T extends Object>();
  Either<ModularError, Unit> releaseScopedBinds();
}
