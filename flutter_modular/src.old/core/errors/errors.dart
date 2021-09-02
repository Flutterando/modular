abstract class ModularFailure implements Exception {
  final String message;
  ModularFailure(this.message);

  @override
  String toString() {
    return "$runtimeType: $message";
  }
}

class ModularError extends ModularFailure {
  ModularError(String message) : super(message);
}
