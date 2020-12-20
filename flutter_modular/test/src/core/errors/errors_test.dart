import 'package:flutter_modular/src/core/errors/errors.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('to string', () {
    expect(ModularError('message').toString(), 'ModularError: message');
  });
}
