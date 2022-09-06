import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';
import 'package:shelf_modular/src/shared/either.dart';

///Implements [BindService]
///Manage the avaiable bind services such as [getBind], [disposeBind]
///and [releaseScopedBinds]
class BindServiceImpl extends BindService {
  ///Instantiate a [injector]
  final Injector injector;

  ///[BindServiceImpl] constructor, receives a [injector]
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
