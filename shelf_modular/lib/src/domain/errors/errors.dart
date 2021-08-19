abstract class ModularError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const ModularError(this.message, [this.stackTrace]);

  String _returnStackTrace() => stackTrace != null ? stackTrace.toString() : '';

  @override
  String toString() {
    return '''$runtimeType: $message

${_returnStackTrace()}
''';
  }
}

class BindNotFoundException extends ModularError {
  const BindNotFoundException(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class RouteNotFoundException extends ModularError {
  const RouteNotFoundException(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class ModuleStartedException extends ModularError {
  const ModuleStartedException(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}
