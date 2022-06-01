import 'package:flutter_modular/src/flutter_modular_module.dart';
import 'package:flutter_modular/src/presenter/modular_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolver injection (ModularBase)', () {
    expect(injector.get<IModularBase>(), isA<ModularBase>());
  });
}
