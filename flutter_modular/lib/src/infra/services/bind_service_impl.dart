import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../../domain/errors/errors.dart';
import '../../domain/services/bind_service.dart';

class BindServiceImpl extends BindService {
  final AutoInjector injector;

  BindServiceImpl(this.injector);

  @override
  Result<bool, ModularError> disposeBind<T extends Object>() {
    final result = injector.disposeSingleton<T>();
    return Success(result != null);
  }

  @override
  Result<T, ModularError> getBind<T extends Object>() {
    try {
      final result = injector.get<T>();
      return Success(result);
    } on AutoInjectorException catch (e, s) {
      return Failure(BindNotFoundException(e.toString(), s));
    }
  }

  @override
  Result<Unit, ModularError> replaceInstance<T>(T instance) {
    final isAdded = injector.isAdded<T>();
    if (!isAdded) {
      return BindNotFoundException('$T unregistred', StackTrace.current).toFailure();
    }

    injector.replaceInstance<T>(instance);
    return Success.unit();
  }
}
