import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';

abstract class BindService {
  Either<ModularError, T> getBind<T extends Object>();
  Either<ModularError, bool> disposeBind<T extends Object>();
  Either<ModularError, Unit> releaseScopedBinds();
}
