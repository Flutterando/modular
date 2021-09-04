import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mocks.dart';

void main() {
  test('instance', () {
    final route = ModuleRoute('/', module: ModuleMock());
    expect(route.name, '/');
  });

  test('copyWith', () {
    final route = ModuleRoute('/', module: ModuleMock());
    expect(route.copyWith().copyWith(name: '/2').name, '/2');
  });
}
