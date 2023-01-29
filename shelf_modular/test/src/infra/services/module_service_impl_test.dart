import 'package:shelf_modular/src/infra/services/module_service_impl.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final tracker = TrackerMock();
  final service = ModuleServiceImpl(tracker);
  final module = ModuleMock();

  group('start', () {
    test('should return true', () {
      tracker.runApp(module);
      expect(service.start(module).isSuccess(), true);
    });
  });

  group('finish', () {
    test('should return true', () {
      tracker.finishApp();
      expect(service.finish().isSuccess(), true);
    });
  });
}
