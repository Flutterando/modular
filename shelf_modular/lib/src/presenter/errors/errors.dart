import 'package:modular_core/modular_core.dart';

class ModuleStartedException extends ModularError {
  const ModuleStartedException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
