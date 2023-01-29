import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/usecases/start_module.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = StartModuleImpl(service);
  final module = ModuleMock();
  test('start module', () {
    when(() => service.start(module)).thenReturn(Success(unit));

    expect(usecase.call(module).isSuccess(), true);
  });
}
