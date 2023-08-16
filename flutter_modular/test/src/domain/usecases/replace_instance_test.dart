import 'package:flutter_modular/src/domain/usecases/replace_instance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = BindServiceMock();
  final usecase = ReplaceInstanceImpl(service);
  test('dispose bind', () {
    const instance = 'String';
    when(() => service.replaceInstance<String>(instance))
        .thenReturn(const Success(unit));

    expect(usecase.call<String>(instance).isSuccess(), true);
  });
}
