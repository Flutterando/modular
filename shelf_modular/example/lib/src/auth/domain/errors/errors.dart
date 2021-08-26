abstract class AuthException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AuthException(this.message, [this.stackTrace]);

  @override
  String toString() {
    return '$runtimeType: $message\n${stackTrace ?? ''}';
  }
}
