import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route child', () {
    final route = ParallelRoute.child(
      '/',
      child: (_, __) => Container(),
      customTransition: CustomTransition(
        transitionBuilder: (_, anim1, anim2, child) => child,
      ),
    );
    expect(route.name, '/');
  });

  test('route empty', () {
    final route = ParallelRoute.empty();
    expect(route.name, '');
  });

  test('route copyWith', () {
    final route = ParallelRoute.module('/', module: MyModule2()).copyWith();
    expect(route.name, '/');
  });

  test('route addParent', () {
    final routeParent = ParallelRoute.empty().copyWith(name: '/parent');
    var route = ParallelRoute.empty().copyWith(name: '/').addParent(routeParent);
    expect(route.name, '/parent/');
  });
}

class MyModule extends Module {}

class MyModule2 extends Module {}
