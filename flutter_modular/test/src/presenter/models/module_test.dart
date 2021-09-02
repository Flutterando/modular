import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('module instance', () {
    final module = InstanceModule();
    expect(module.binds, const []);
    expect(module.imports, const []);
    expect(module.routes, const []);
  });
}

class InstanceModule extends Module {}
