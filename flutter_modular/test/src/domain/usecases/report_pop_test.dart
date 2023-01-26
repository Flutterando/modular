import 'package:flutter_modular/src/domain/usecases/report_pop.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';
import '../../presenter/modular_base_test.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = ReportPopImpl(service);
  final route = ParallelRouteMock();
  test('ReportPopImpl', () {
    when(() => service.reportPop(route)).thenReturn(const Success(unit));

    expect(usecase.call(route).getOrNull(), unit);
  });
}
