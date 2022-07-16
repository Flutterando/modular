import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';
import 'package:shelf_modular/src/infra/services/module_service_impl.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  late Tracker tracker;
  late Injector injectorMock;
  late ModuleService service;
  late RouteContext module;

  setUp(() {
    tracker = TrackerMock();
    injectorMock = InjectorMock();
    service = ModuleServiceImpl(tracker);
    module = RouteContextMock();
  });

  tearDown(() {
    reset(tracker);
    reset(injectorMock);
    reset(module);
  });

  group('start', () {
    test('should return true', () {
      tracker.runApp(module);
      expect(service.start(module).isRight, true);
    });
  });

  group('finish', () {
    test('should return true', () {
      tracker.finishApp();
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
    });
  });
}
