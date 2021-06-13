import 'package:flutter/material.dart';
import 'package:flutter_modular/src/core/interfaces/modular_route.dart';
import 'package:flutter_modular/src/core/models/custom_transition.dart';
import 'package:flutter_modular/src/presenters/modular_route_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../modules/child_module_test.dart';

void main() {
  group('ModularRoute', () {
    test("can't have both module and child", () {
      expect(
        () => ModularRouteImpl(
          '/',
          child: (_, __) => Container(),
          module: ModuleMock(),
        ),
        throwsAssertionError,
      );
    });

    test("can't have both module and children", () {
      expect(
        () => ModularRouteImpl(
          '/',
          module: ModuleMock(),
          children: [
            ModularRouteImpl('/home'),
            ModularRouteImpl('/config'),
          ],
        ),
        throwsAssertionError,
      );
    });

    group('transitions', () {
      test(
          "can't have a transition of type customTransition without a transition builder",
          () {
        expect(
          () => ModularRouteImpl(
            '/',
            transition: TransitionType.custom,
            module: ModuleMock(),
          ),
          throwsAssertionError,
        );
      });
      test(
          "can have a transition of type customTransition given a transition builder",
          () {
        late ModularRoute route;
        expect(
          () {
            route = ModularRouteImpl(
              '/',
              transition: TransitionType.custom,
              module: ModuleMock(),
              customTransition: CustomTransition(
                transitionBuilder: (_, animation, __, ___) {
                  return FadeTransition(
                    opacity: animation,
                  );
                },
              ),
            );
          },
          isNot(throwsAssertionError),
        );
        expect(route.transition, TransitionType.custom);
      });
    });

    group('creates a copy', () {
      test('similar to the original', () {
        final original = ModularRouteImpl('/', module: ModuleMock());
        final copy = original.copyWith();
        expect(original, copy);
        expect(original.hashCode, copy.hashCode);
      });

      test('with the same fields except the ones provided', () {
        final module = ModuleMock();
        final original = ModularRouteImpl('/', module: module);
        final copy = original.copyWith(
          uri: Uri.parse('/home'),
          transition: TransitionType.fadeIn,
        );
        expect(copy.path, isNot(equals(original.path)));
        expect(copy.module, module);
        expect(copy.transition, isNot(original.transition));
      });
    });
  });
}
