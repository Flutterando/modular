import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  test('Create arguments', () {
    final args = ModularArguments(
      uri: Uri.parse('/'),
      params: {'test': 'test'},
      data: 0,
    );

    final copy = args.copyWith(data: 1);
    expect(copy.data, 1);
    expect(copy.queryParamsAll, {});
    expect(copy.fragment, '');
  });
}
