import 'package:flutter_modular/src/core/models/bind.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('check type', () {
    final bind = Bind.instance('teste');
    expect(bind, isA<Bind<String>>());
  });
}
