import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

main() {
  group("Bind", () {
    test('correct', () {
      expect(Bind((i) => 'obs'), isA<Bind>());
      expect(Bind((i) => 'obs', singleton: true, lazy: true), isA<Bind>());
      expect(Bind((i) => 'obs', singleton: true, lazy: false), isA<Bind>());
      expect(Bind((i) => 'obs', singleton: false, lazy: true), isA<Bind>());
    });
    test('error', () {
      expect(
        () => Bind((i) => 'obs', singleton: false, lazy: false),
        throwsAssertionError,
      );
    });
  });
}
