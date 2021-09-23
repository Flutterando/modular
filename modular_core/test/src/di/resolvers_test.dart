import 'package:modular_core/src/di/resolvers.dart';
import 'package:test/test.dart';

void main() {
  test('disposeResolverFunc', () {
    var value;
    setDisposeResolver((r) {
      value = r;
    });
    disposeResolverFunc?.call('.');
    expect(value, '.');
  });
  test('printResolver', () {
    var text;
    setPrintResolver((t) {
      text = t;
    });
    printResolverFunc?.call('.');
    expect(text, '.');
  });
}
