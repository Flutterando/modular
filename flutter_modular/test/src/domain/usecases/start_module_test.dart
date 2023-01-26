import 'package:flutter_modular/src/domain/usecases/start_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = StartModuleImpl(service);
  final module = ModuleMock();
  test('start module', () {
    when(() => service.start(module)).thenReturn(const Success(unit));

    expect(usecase.call(module).isSuccess(), true);
  });
}
