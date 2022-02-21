import 'package:modular_core/src/di/resolvers.dart';
import 'package:test/test.dart';

void main() {
  test('disposeResolverFunc', () {
    dynamic value;
    setDisposeResolver((r) {
      value = r;
    });
    disposeResolverFunc?.call('.');
    expect(value, '.');
  });
  test('printResolver', () {
    dynamic text;
    setPrintResolver((t) {
      text = t;
    });
    printResolverFunc?.call('.');
    expect(text, '.');
  });
}
