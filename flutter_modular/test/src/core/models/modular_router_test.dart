import 'package:flutter/material.dart';
import 'package:flutter_modular/src/core/interfaces/modular_route.dart';
import 'package:flutter_modular/src/core/models/custom_transition.dart';
import 'package:flutter_modular/src/presenters/modular_route_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../modules/child_module_test.dart';

main() {
  test('should initializa in incorrect form', () {
    expect(
        () => ModularRouteImpl('/',
            child: (context, args) => Container(), module: ModuleMock()),
        throwsAssertionError);

    expect(
        () => ModularRouteImpl('/',
            transition: TransitionType.custom, module: ModuleMock()),
        throwsAssertionError);

    expect(
        () => ModularRouteImpl('/',
            children: [ModularRouteImpl('/')], module: ModuleMock()),
        throwsAssertionError);
  });

  test('should make copy with implementation', () {
    final model = ModularRouteImpl('/', module: ModuleMock());
    final copy = model.copyWith();
    expect(copy.module, isA<ModuleMock>());
    final copy2 = model.copyWith(uri: Uri.parse('/home'));
    expect(copy2.module, isA<ModuleMock>());
    expect(copy2.path, '/home');
    expect(copy.hashCode, equals(copy2.hashCode));
    expect(copy == copy2, true);
  });

  test('should normal instance custom transition', () {
    final model = ModularRouteImpl('/',
        transition: TransitionType.custom, module: ModuleMock(),
        customTransition: CustomTransition(transitionBuilder: (c, a1, a2, w) {
      return FadeTransition(
        opacity: a1,
      );
    }));
    expect(model.transition, TransitionType.custom);
  });
}
