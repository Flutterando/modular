import 'package:flutter_modular/src/domain/usecases/set_arguments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = SetArgumentsImpl(service);
  test('set ModularArguments', () {
    final args = ModularArguments.empty();
    when(() => service.setArguments(args)).thenReturn(const Success(unit));

    expect(usecase.call(args).getOrElse((l) => throw l), unit);
  });
}
