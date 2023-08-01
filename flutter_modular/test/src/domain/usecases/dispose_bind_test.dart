import 'package:flutter_modular/src/domain/usecases/dispose_bind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = BindServiceMock();
  final usecase = DisposeBindImpl(service);
  test('dispose bind', () {
    when(() => service.disposeBind<String>()).thenReturn(const Success(true));

    expect(usecase.call<String>().getOrNull(), true);
  });
}
