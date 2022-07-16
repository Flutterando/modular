import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_modular/src/infra/services/route_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_core/modular_core.dart';

import '../../mocks/mocks.dart';
import '../../presenter/modular_base_test.dart';

void main() {
  final tracker = TrackerMock();
  final service = RouteServiceImpl(tracker);
  const params = RouteParmsDTO(url: '/');

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

  group('setArguments', () {
    test('should set args', () async {
      final args = ModularArguments.empty();
      when(() => tracker.setArguments(args)).thenReturn(null);
      final result = service.setArguments(args);
      expect(result.isRight, true);
    });
  });

  group('reportPop', () {
    test('should send route', () async {
      final route = ParallelRouteMock();
      when(() => tracker.reportPopRoute(route)).thenReturn(null);
      final result = service.reportPop(route);
      expect(result.isRight, true);
    });
  });

  group('reportPush', () {
    test('should send route', () async {
      final route = ParallelRouteMock();
      when(() => tracker.reportPushRoute(route)).thenReturn(null);
      final result = service.reportPush(route);
      expect(result.isRight, true);
    });
  });
  group('reassemble', () {
    test('should call reassemble', () async {
      when(() => tracker.reassemble()).thenReturn(null);
      final result = service.reassemble();
      expect(result.isRight, true);
    });
  });
}
