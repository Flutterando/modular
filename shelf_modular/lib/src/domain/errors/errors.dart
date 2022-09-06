import 'package:modular_core/modular_core.dart';

///[ModularError] class for bind not found
///receives a [message] and [stackTrace] of the error
class BindNotFoundException extends ModularError {
  ///[BindNotFoundException] constructor
  const BindNotFoundException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

///[ModularError] class for route not found
///receives a [message] and [stackTrace] of the error
class RouteNotFoundException extends ModularError {
  ///[RouteNotFoundException] constructor
  const RouteNotFoundException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
