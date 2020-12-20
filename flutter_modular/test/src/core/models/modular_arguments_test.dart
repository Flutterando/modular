import 'package:flutter_modular/src/core/models/modular_arguments.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('should make copy with implementation', () {
    final model = ModularArguments.empty();
    final copy = model.copyWith();
    expect(model != copy, true);
  });
}
