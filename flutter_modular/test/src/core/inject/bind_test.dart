import 'package:flutter_modular/src/core/models/bind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bind', () {
    group('factories', () {
      test('defaults to lazy and singleton', () {
        final bind = Bind((_) => 'some dependency');
        expect(bind.isSingleton, isTrue);
        expect(bind.isLazy, isTrue);
        expect(bind.export, isFalse);
      });

      test("can't be both singleton and lazy", () {
        expect(
          () => Bind((i) => String, isLazy: false, isSingleton: false),
          throwsAssertionError,
        );
      });
    });
  });
}
