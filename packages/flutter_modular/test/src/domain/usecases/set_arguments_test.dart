import 'package:flutter_modular/src/domain/usecases/set_arguments.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = SetArgumentsImpl(service);
  test('set ModularArguments', () {
    final args = ModularArguments.empty();
    when(() => service.setArguments(args)).thenReturn(right(unit));

    expect(usecase.call(args).getOrElse((l) => throw l), unit);
  });
}
