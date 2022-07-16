import 'package:flutter/material.dart';
import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('module instance', () {
    final module = InstanceModule();
    expect(module.binds, const []);
    expect(module.imports, const []);
    expect(module.routes, const []);
  });

  test('copy', () {
    final module = InstanceModule();
    final parent = ParallelRoute.child('/', child: (_, __) => Container());
    final route = ParallelRoute.child('/', child: (_, __) => Container());
    final result = module.copy(parent, route);
    expect(result.name, '/');
  });
}

class InstanceModule extends Module {}
