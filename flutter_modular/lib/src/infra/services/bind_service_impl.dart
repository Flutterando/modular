import 'package:modular_core/modular_core.dart';

import '../../domain/errors/errors.dart';
import '../../domain/services/bind_service.dart';
import '../../shared/either.dart';

class BindServiceImpl extends BindService {
  final Injector injector;

  BindServiceImpl(this.injector);

  @override
  Either<ModularError, bool> disposeBind<T extends Object>() {
    final result = injector.dispose<T>();
    return right(result);
  }

  @override
  Either<ModularError, BindEntry<T>> getBind<T extends Object>() {
    try {
      final result = injector.getBind<T>();
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
