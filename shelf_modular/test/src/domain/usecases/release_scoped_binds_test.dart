import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/domain/usecases/release_scoped_binds.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = BindServiceMock();
  final usecase = ReleaseScopedBindsImpl(service);
  test('get ModularArguments', () {
    when(() => service.releaseScopedBinds()).thenReturn(right(unit));
    expect(usecase.call().getOrElse((left) => throw left), unit);
  });
}
