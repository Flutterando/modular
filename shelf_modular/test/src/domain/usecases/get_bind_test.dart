import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/usecases/get_bind.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = BindServiceMock();
  final usecase = GetBindImpl(service);
  test('get bind', () {
    when(() => service.getBind<String>()).thenReturn(const Success('test'));

    expect(usecase.call<String>().getOrElse((left) => ''), 'test');
  });
}
