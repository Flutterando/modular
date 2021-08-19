import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/infra/services/route_service_impl.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final tracker = TrackerMock();
  final service = RouteServiceImpl(tracker);
  final params = RouteParmsDTO(url: '/');

  group('getBind', () {
    test('should get bind', () async {
      when(() => tracker.findRoute(params.url)).thenAnswer((_) async => ModularRouteMock());
      final result = await service.getRoute(params);
      expect(result.isRight, true);
    });
    test('should throw error not found route', () async {
      when(() => tracker.findRoute(params.url)).thenAnswer((_) async => null);
      final result = await service.getRoute(params);
      expect(result.isLeft, true);
    });
  });
}
