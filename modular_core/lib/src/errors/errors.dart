part of '../../modular_core.dart';

abstract class ModularError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const ModularError(this.message, [this.stackTrace]);

  String _returnStackTrace() => stackTrace != null ? '\n$stackTrace' : '';

  @override
  String toString() => '$runtimeType: $message${_returnStackTrace()}';
}

class TrackerNotInitiated extends ModularError {
  const TrackerNotInitiated(
    String message, [
    StackTrace? stackTrace,
  ]) : super(message, stackTrace);
}
