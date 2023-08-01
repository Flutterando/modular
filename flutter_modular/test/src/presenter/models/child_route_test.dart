import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('instance', () {
    final route = ChildRoute('/', child: (context) => Container());
    expect(route.name, '/');
  });

  test('Don\'t use name "/" in route\'s children when parent be "/" too', () {
    final route = ChildRoute('/', child: (context) => Container());
    expect(
        () =>
            ChildRoute('/', child: (context) => Container(), children: [route]),
        throwsAssertionError);
  });

  test('The name must always start with a /', () {
    expect(() => ChildRoute('test', child: (context) => Container()),
        throwsAssertionError);
  });
}
