import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../../domain/errors/errors.dart';
import '../../domain/services/bind_service.dart';

class BindServiceImpl extends BindService {
  final AutoInjector injector;

  BindServiceImpl(this.injector);

  @override
  ResultDart<bool, ModularError> disposeBind<T extends Object>([String? key]) {
    final result = injector.disposeSingleton<T>(key: key);
    return Success(result != null);
  }

  @override
  ResultDart<T, ModularError> getBind<T extends Object>([String? key]) {
    try {
      final result = injector.get<T>(key: key);
      return Success(result);
    } on AutoInjectorException catch (e, s) {
      return Failure(BindNotFoundException(e.toString(), s));
    }
  }

  @override
  ResultDart<Unit, ModularError> replaceInstance<T>(T instance, [String? key]) {
    injector.replaceInstance(instance, key: key);
    return Success.unit();
  }
}
