import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/infra/services/route_service_impl.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

class ModularRouteFake extends Fake implements ModularRoute {}

void main() {
  final tracker = TrackerMock();
  final service = RouteServiceImpl(tracker);
  const params = RouteParmsDTO(url: '/');

  setUp(() {
    reset(tracker);
  });

  group('getRoute', () {
    test('should get route', () async {
      when(() => tracker.findRoute(params.url)).thenAnswer(
        (_) async => ModularRouteFake(),
      );
      final result = await service.getRoute(params);
      expect(result.isSuccess(), true);
    });
    test('should throw error not found route', () async {
      when(() => tracker.findRoute(params.url)).thenReturn(null);
      final result = await service.getRoute(params);
      expect(result.isError(), true);
    });
  });

  group('getArguments', () {
    test('should return args', () async {
      when(() => tracker.arguments).thenReturn(ModularArguments.empty());
      final result = service.getArguments();
      expect(result.isSuccess(), true);
    });
  });

  group('reportPush', () {
    test('report pushroute', () async {
      final route = RouteMock();
      when(() => tracker.reportPopRoute(route));
      final result = service.reportPush(route);
      expect(result.isSuccess(), true);
    });
  });
}
