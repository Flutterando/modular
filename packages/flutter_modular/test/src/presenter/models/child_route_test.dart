import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('instance', () {
    var route = ChildRoute('/', child: (context, args) => Container());
    expect(route.name, '/');
  });

  test('Don\'t use name "/" in route\'s children when parent be "/" too', () {
    var route = ChildRoute('/', child: (context, args) => Container());
    expect(
        () => ChildRoute('/',
            child: (context, args) => Container(), children: [route]),
        throwsAssertionError);
  });

  test('The name must always start with a /', () {
    expect(() => ChildRoute('test', child: (context, args) => Container()),
        throwsAssertionError);
  });
}
