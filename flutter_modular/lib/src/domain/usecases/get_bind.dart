import 'package:modular_core/modular_core.dart';
import '../../shared/either.dart';
import '../services/bind_service.dart';

abstract class GetBind {
  Either<ModularError, BindEntry<T>> call<T extends Object>();
}

class GetBindImpl implements GetBind {
  final BindService bindService;

  GetBindImpl(this.bindService);

  @override
  Either<ModularError, BindEntry<T>> call<T extends Object>() {
    return bindService.getBind<T>();
  }
}
