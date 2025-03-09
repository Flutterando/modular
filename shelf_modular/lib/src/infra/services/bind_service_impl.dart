import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';

class BindServiceImpl extends BindService {
  final AutoInjector injector;

  BindServiceImpl(this.injector);

  @override
  ResultDart<bool, ModularError> disposeBind<T extends Object>() {
    final result = injector.disposeSingleton<T>();
    return Success(result != null);
  }

  @override
  ResultDart<T, ModularError> getBind<T extends Object>() {
    try {
      final result = injector.get<T>();
      return Success(result);
    } on AutoInjectorException catch (e, s) {
      return Failure(BindNotFoundException(e.toString(), s));
    }
  }
}
