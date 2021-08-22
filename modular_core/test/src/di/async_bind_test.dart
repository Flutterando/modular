import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  final asyncBind = AsyncBind((i) => Future.value(''));
  test('resolve resolveAsyncBind', () {
    expect(asyncBind.resolveAsyncBind(), completion(''));
  });
  test('resolve convertToAsyncBind', () {
    expect(asyncBind.convertToAsyncBind(), completion(isA<BindContract<String>>()));
  });
}
