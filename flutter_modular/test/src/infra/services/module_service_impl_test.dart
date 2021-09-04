import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/infra/services/module_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('bind', () {
    test('should execute', () async {
      when(() => tracker.injector).thenReturn(injectorMock);
      when(() => injectorMock.bindContext(module)).thenReturn(true);
      final result = service.bind(module);
      expect(result.isRight, true);
    });
  });

  group('unbind', () {
    test('should execute', () async {
      when(() => tracker.injector).thenReturn(injectorMock);
      when(() => injectorMock.removeBindContext()).thenReturn(true);
      final result = service.unbind();
      expect(result.isRight, true);
    });
  });
}
