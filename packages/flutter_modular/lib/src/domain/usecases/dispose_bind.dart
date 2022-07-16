import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../services/bind_service.dart';

abstract class DisposeBind {
  Either<ModularError, bool> call<T extends Object>();
}

class DisposeBindImpl implements DisposeBind {
  final BindService bindService;

  DisposeBindImpl(this.bindService);

  @override
  Either<ModularError, bool> call<T extends Object>() {
    return bindService.disposeBind<T>();
  }
}
