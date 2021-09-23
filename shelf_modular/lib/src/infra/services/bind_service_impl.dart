import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';

class BindServiceImpl extends BindService {
  final Injector injector;

  BindServiceImpl(this.injector);

  @override
  Either<ModularError, bool> disposeBind<T extends Object>() {
    final result = injector.dispose<T>();
    return right(result);
  }

  @override
  Either<ModularError, T> getBind<T extends Object>() {
    try {
      final result = injector.get<T>();
      return right(result);
    } on BindNotFound catch (e, s) {
      return left(BindNotFoundException('$T not found.', s));
    }
  }

  @override
  Either<ModularError, Unit> releaseScopedBinds() {
    injector.removeScopedBinds();
    return right(unit);
  }
}
