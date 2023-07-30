import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

import '../models/route_test.dart';

void main() {
  test('Extension method', () {
    final manager = RouteManager();
    manager.child('/', child: (context) => Container());
    manager.redirect('/', to: '/other');
    manager.wildcard(child: (context) => Container());
    manager.module('/', module: MyModule());

    expect(manager.args, isA<ModularArguments>());
    expect(manager.allRoutes, [
      isA<ChildRoute>(),
      isA<RedirectRoute>(),
      isA<WildcardRoute>(),
      isA<ModuleRoute>(),
    ]);
  });
}
