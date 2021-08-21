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
