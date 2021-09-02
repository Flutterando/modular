import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/usecases/finish_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = FinishModuleImpl(service);
  test('finish module', () {
    when(() => service.finish()).thenReturn(right(unit));

    expect(usecase.call().isRight, true);
  });
}
