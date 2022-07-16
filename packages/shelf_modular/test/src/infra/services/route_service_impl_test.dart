import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';
import 'package:shelf_modular/src/infra/services/route_service_impl.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';
import '../../presenter/modular_base_test.dart';

void main() {
  late Tracker tracker;
  late RouteService service;
  final params = RouteParmsDTO(url: '/');

  setUpAll(() {
    tracker = TrackerMock();
    service = RouteServiceImpl(tracker);
  });

  tearDown(() {
    reset(tracker);
  });

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
}
