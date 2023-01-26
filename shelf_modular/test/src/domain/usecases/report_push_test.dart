import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = ReportPushImpl(service);
  test('report push route', () {
    final route = RouteMock();
    when(() => service.reportPush(route)).thenReturn(Success(unit));
    final result = usecase.call(route);
    expect(result.isSuccess(), true);
  });
}
