import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';
import '../../presenter/modular_base_test.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = ReportPushImpl(service);
  test('report push route', () {
    final route = RouteMock();
    when(() => service.reportPush(route)).thenReturn(right(unit));
    final result = usecase.call(route);
    expect(result.isRight, true);
  });
}
