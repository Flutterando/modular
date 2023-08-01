import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/usecases/finish_module.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = FinishModuleImpl(service);
  test('finish module', () {
    when(service.finish).thenReturn(const Success(unit));

    expect(usecase.call().isSuccess(), true);
  });
}
