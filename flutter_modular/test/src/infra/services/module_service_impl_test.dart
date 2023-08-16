import 'package:flutter_modular/src/infra/services/module_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../../mocks/mocks.dart';

class TrackerMock extends Mock implements Tracker {}

void main() {
  late TrackerMock tracker;
  late ModuleMock module;
  late ModuleServiceImpl service;

  setUp(() {
    tracker = TrackerMock();
    module = ModuleMock();
    service = ModuleServiceImpl(tracker);
  });

  group('start', () {
    test('should return true', () {
      tracker.runApp(module);
      expect(service.start(module).isSuccess(), true);
    });
  });

  group('finish', () {
    test('should return true', () {
      expect(service.finish().isSuccess(), true);
    });
  });

  group('bind', () {
    test('should execute', () {
      when(() => tracker.bindModule(module));
      final result = service.bind(module);
      expect(result.isSuccess(), true);
      expect(result.getOrNull(), unit);
    });
  });

  group('unbind', () {
    test('should execute', () {
      //  when(() => tracker.unbindModule('ModuleMock'));
      final result = service.unbind<ModuleMock>();
      expect(result.isSuccess(), true);
    });
  });
}
