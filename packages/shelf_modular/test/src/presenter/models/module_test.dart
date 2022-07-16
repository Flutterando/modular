import 'package:shelf_modular/shelf_modular.dart';
import 'package:test/test.dart';

void main() {
  test('module instance', () {
    final module = InstanceModule();
    expect(module.binds, const []);
    expect(module.imports, const []);
    expect(module.routes, const []);
  });
}

class InstanceModule extends Module {}
