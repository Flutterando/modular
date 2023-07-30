import 'package:flutter_modular/src/domain/usecases/get_bind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = BindServiceMock();
  final usecase = GetBindImpl(service);
  test('get bind', () {
    when(() => service.getBind<String>()).thenReturn(const Success('test'));

    expect(usecase.call<String>().getOrNull(), 'test');
  });
}
