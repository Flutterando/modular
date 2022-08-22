import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/infra/services/route_service_impl.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';
import '../../presenter/modular_base_test.dart';

void main() {
  final tracker = TrackerMock();
  final service = RouteServiceImpl(tracker);
  final params = RouteParmsDTO(url: '/');

  group('getRoute', () {
    test('should get route', () async {
      when(() => tracker.findRoute(params.url))
          .thenAnswer((_) async => ModularRouteMock());
      final result = await service.getRoute(params);
      expect(result.isRight, true);
    });
    test('should throw error not found route', () async {
      when(() => tracker.findRoute(params.url)).thenAnswer((_) async => null);
      final result = await service.getRoute(params);
      expect(result.isLeft, true);
    });
  });

  group('getArguments', () {
    test('should return args', () async {
      when(() => tracker.arguments).thenReturn(ModularArguments.empty());
      final result = service.getArguments();
      expect(result.isRight, true);
    });
  });

  group('reportPush', () {
    test('report pushroute', () async {
      final route = RouteMock();
      when(() => tracker.reportPopRoute(route));
      final result = service.reportPush(route);
      expect(result.isRight, true);
    });
  });

  group('reassemble', () {
    test('return unit', () async {
      final result = service.reassemble();
      expect(result.isRight, true);
    });
  });
}
