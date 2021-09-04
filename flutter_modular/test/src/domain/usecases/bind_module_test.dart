import 'package:flutter_modular/src/domain/usecases/bind_module.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = BindModuleImpl(service);
  final module = ModuleMock();
  test('BindModuleImpl', () {
    when(() => service.bind(module)).thenReturn(right(unit));

    expect(usecase.call(module).getOrElse((l) => throw l), unit);
  });
}
