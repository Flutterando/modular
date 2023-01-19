import 'package:modular_core/src/di/resolvers.dart';
import 'package:test/test.dart';

void main() {
  test('printResolver', () {
    dynamic text;
    setPrintResolver((t) {
      text = t;
    });
    printResolverFunc?.call('.');
    expect(text, '.');
  });
}
