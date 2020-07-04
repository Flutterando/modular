import 'package:flutter/material.dart';
import 'package:flutter_modular/src/transitions/transitions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fadeInTransition', () {
    var r = fadeInTransition((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('noTransition', () {
    var r = noTransition((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('rightToLeft', () {
    var r = rightToLeft((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('leftToRight', () {
    var r = leftToRight((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('upToDown', () {
    var r = upToDown((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('downToUp', () {
    var r = downToUp((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('scale', () {
    var r = scale((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });

  test('rotate', () {
    var r = rotate((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('size', () {
    var r = size((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('rightToLeftWithFade', () {
    var r = rightToLeftWithFade((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
  test('leftToRightWithFade', () {
    var r = leftToRightWithFade((context, args) => Container(), null, null);
    expect(r, isA<PageRouteBuilder>());
  });
}
