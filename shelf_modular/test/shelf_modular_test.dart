import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/presenter/modular_base.dart';
import 'package:test/test.dart';

void main() {
  test('Modular instance', () {
    expect(Modular, isA<IModularBase>());
  });
}
