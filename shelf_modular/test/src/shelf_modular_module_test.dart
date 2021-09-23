import 'package:shelf_modular/src/presenter/modular_base.dart';
import 'package:shelf_modular/src/shelf_modular_module.dart';
import 'package:test/test.dart';

void main() {
  test('resolver injection (ModularBase)', () {
    expect(injector.get<IModularBase>(), isA<ModularBase>());
  });
}
