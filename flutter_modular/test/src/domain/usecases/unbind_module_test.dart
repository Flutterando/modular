import 'package:flutter_modular/src/domain/usecases/unbind_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = UnbindModuleImpl(service);
  test('UnbindModuleImpl', () {
    when(service.unbind).thenReturn(const Success(unit));

    expect(usecase.call().getOrNull(), unit);
  });
}
