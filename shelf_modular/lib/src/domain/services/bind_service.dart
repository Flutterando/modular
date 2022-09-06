import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/shared/either.dart';

///An interface for bind services
abstract class BindService {
  ///Get bind
  Either<ModularError, T> getBind<T extends Object>();
  ///Remove bind
  Either<ModularError, bool> disposeBind<T extends Object>();
  ///Remove binds from scope
  Either<ModularError, Unit> releaseScopedBinds();
}
