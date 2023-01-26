import 'package:flutter_modular/src/domain/usecases/report_push.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';
import '../../presenter/modular_base_test.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = ReportPushImpl(service);
  test('report push route', () {
    final route = ParallelRouteMock();
    when(() => service.reportPush(route)).thenReturn(const Success(unit));
    final result = usecase.call(route);
    expect(result.isSuccess(), true);
  });
}
