import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/domain/usecases/reassemble_tracker.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = ReassembleTrackerImpl(service);
  test('Reassemble tracker', () {
    when(() => service.reassemble()).thenReturn(right(unit));

    expect(usecase.call().getOrElse((l) => throw l), unit);
  });
}
