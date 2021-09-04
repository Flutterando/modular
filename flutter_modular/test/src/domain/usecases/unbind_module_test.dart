import 'package:flutter_modular/src/domain/usecases/unbind_module.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = UnbindModuleImpl(service);
  test('UnbindModuleImpl', () {
    when(() => service.unbind()).thenReturn(right(unit));

    expect(usecase.call().getOrElse((l) => throw l), unit);
  });
}
