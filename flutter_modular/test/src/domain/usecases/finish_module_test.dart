import 'package:flutter_modular/src/domain/usecases/finish_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = FinishModuleImpl(service);
  test('finish module', () {
    when(() => service.finish()).thenReturn(const Success(unit));

    expect(usecase.call().isSuccess(), true);
  });
}
