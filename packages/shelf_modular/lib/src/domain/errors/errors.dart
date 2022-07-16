import 'package:modular_core/modular_core.dart';

class BindNotFoundException extends ModularError {
  const BindNotFoundException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class RouteNotFoundException extends ModularError {
  const RouteNotFoundException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
