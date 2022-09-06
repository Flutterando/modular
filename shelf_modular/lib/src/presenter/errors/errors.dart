import 'package:modular_core/modular_core.dart';

///[ModularError] class for module started
///receives a [message] and [stackTrace] of the error
class ModuleStartedException extends ModularError {
  ///[ModuleStartedException] constructor
  const ModuleStartedException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
