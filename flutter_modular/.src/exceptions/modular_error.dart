class ModularError implements Exception {
  final String message;

  ModularError(this.message);

  @override
  String toString() {
    return "ModularError: $message";
  }
}
