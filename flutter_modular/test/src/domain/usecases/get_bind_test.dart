import 'package:flutter_modular/flutter_modular.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/usecases/get_bind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_core/modular_core.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = BindServiceMock();
  final usecase = GetBindImpl(service);
  test('get bind', () {
    when(() => service.getBind<String>()).thenReturn(
        right(BindEntry(bind: Bind<String>((i) => ''), value: 'test')));

    expect(usecase.call<String>().map((r) => r.value).getOrElse((left) => ''),
        'test');
  });
}
