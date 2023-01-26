import 'package:flutter_modular/src/domain/usecases/get_arguments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = GetArgumentsImpl(service);
  test('get ModularArguments', () {
    final args = ModularArguments.empty();
    when(() => service.getArguments()).thenReturn(Success(args));

    expect(usecase.call().getOrElse((left) => ModularArguments.empty()), args);
  });
}
