import 'package:flutter_modular/src/core/models/modular_arguments.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('should make copy with implementation', () {
    final model =
        ModularArguments(data: 'data', params: {}, uri: Uri.parse("/route"));
    final copy = model.copyWith();
    expect(model, isNot(equals(copy)));
    expect(model.params, copy.params);
    expect(model.data, copy.data);
    expect(model.uri, copy.uri);
  });
}
