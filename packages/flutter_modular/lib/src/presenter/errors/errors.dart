import 'package:modular_core/modular_core.dart';

class ModuleStartedException extends ModularError {
  const ModuleStartedException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class GuardedRouteException extends ModularError {
  GuardedRouteException(String path) : super(path);
}

class ModularPageException extends ModularError {
  ModularPageException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
