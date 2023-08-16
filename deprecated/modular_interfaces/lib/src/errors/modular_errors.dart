abstract class ModularError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const ModularError(this.message, [this.stackTrace]);

  String _returnStackTrace() =>
      stackTrace != null ? '\n${stackTrace.toString()}' : '';

  @override
  String toString() => '$runtimeType: $message${_returnStackTrace()}';
}
