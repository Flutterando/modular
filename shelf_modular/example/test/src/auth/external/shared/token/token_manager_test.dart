import 'package:example/src/auth/external/shared/token/token_manager.dart';
import 'package:test/test.dart';

void main() {
  late TokenManager manager;
  setUp(() {
    manager = TokenManager();
  });

  test('generateToken', () {
    final exp = Duration(milliseconds: DateTime.now().add(Duration(seconds: 20)).millisecondsSinceEpoch).inSeconds;
    print(exp);

    final token = manager.generateToken({
      'exp': exp,
    });

    print(token);
  });

  test('validateToken', () async {
    final token = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2Mjk5OTI1MTl9.-uReOTXchL_-vQnhKwVw4zulDRWXEavyWCp71fZp99o';
    await manager.validateToken(token);
  });
}
