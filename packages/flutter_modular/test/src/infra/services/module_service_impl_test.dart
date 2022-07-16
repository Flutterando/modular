import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/infra/services/module_service_impl.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';

class TrackerMock extends Mock implements Tracker {}

class InjectorMock extends Mock implements Injector {}

class RouteContextMock extends Mock implements RouteContext {}

void main() {
  late Tracker tracker;
  late Injector injectorMock;
  late RouteContext module;
  late ModuleServiceImpl service;

  setUpAll(() {
    tracker = TrackerMock();
    injectorMock = InjectorMock();
    module = RouteContextMock();
    service = ModuleServiceImpl(tracker);
  });

  group('start', () {
    test('should return true', () {
      tracker.runApp(module);
      expect(service.start(module).isRight, true);
    });
  });

  group('finish', () {
    test('should return true', () {
      expect(service.finish().isRight, true);
    });
  });

  group('isModuleReady', () {
    test('should return true', () async {
      when(() => tracker.injector).thenReturn(injectorMock);
      when(() => injectorMock.isModuleReady<Module>())
          .thenAnswer((_) async => true);

      final result = await service.isModuleReady<Module>();
      expect(result.isRight, true);
      final isReady = result.getOrElse((left) => false);
      expect(isReady, true);
    });
  });

  group('bind', () {
    test('should execute', () async {
      when(() => tracker.injector).thenReturn(injectorMock);
      injectorMock.addBindContext(module);
      final result = service.bind(module);
      expect(result.isRight, true);
      final bindContext = result.getOrElse((left) => unit);
      expect(result.isRight, true);
      expect(bindContext, unit);
    });
  });

  group('unbind', () {
    test('should execute', () async {
      when(() => tracker.injector).thenReturn(injectorMock);
      final result = service.unbind();
      expect(result.isRight, true);
    });
  });
}
