import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/usecases/module_ready.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = ModuleServiceMock();
  final usecase = IsModuleReadyImpl(service);
  test('check module is ready', () async {
    when(() => service.isModuleReady()).thenAnswer((_) async => right(true));
    final result = await usecase.call();
    expect(result.isRight, true);
  });
}
