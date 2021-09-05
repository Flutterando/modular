import 'package:example/src/auth/domain/errors/errors.dart';

class NotAuthorized extends AuthException {
  const NotAuthorized(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class JWTViolations extends AuthException {
  final List<String> violations;
  const JWTViolations(
    String message,
    this.violations,
  ) : super(message);

  @override
  String toString() {
    return 'JWTViolations: $message\n$violations';
  }
}
