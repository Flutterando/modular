import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/core/either.dart';
import 'package:shelf_modular/src/infra/services/module_service_impl.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final tracker = TrackerMock();
  final injectorMock = InjectorMock();
  final service = ModuleServiceImpl(tracker);
  final module = RouteContextMock();

  group('start', () {
    test('should return true', () {
      when(() => tracker.runApp(module)).thenReturn(unit);
      expect(service.start(module).isRight, true);
    });
  });

  group('finish', () {
    test('should return true', () {
      when(() => tracker.finishApp()).thenReturn(unit);
      expect(service.finish().isRight, true);
    });
  });

  group('isModuleReady', () {
    test('should return true', () async {
      when(() => tracker.injector).thenReturn(injectorMock);
      when(() => injectorMock.isModuleReady()).thenAnswer((_) async => true);
      final result = await service.isModuleReady();
      expect(result.isRight, true);
    });
  });
}
