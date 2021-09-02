import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/usecases/start_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = StartModuleImpl(service);
  final module = RouteContextMock();
  test('start module', () {
    when(() => service.start(module)).thenReturn(right(unit));

    expect(usecase.call(module).isRight, true);
  });
}
