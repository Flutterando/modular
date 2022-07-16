import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:shelf_modular/src/domain/usecases/dispose_bind.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = BindServiceMock();
  final usecase = DisposeBindImpl(service);
  test('dispose bind', () {
    when(() => service.disposeBind<String>()).thenReturn(right(true));

    expect(usecase.call<String>().getOrElse((left) => false), true);
  });
}
