import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('instance', () {
    final route = WildcardRoute(child: (_, __) => Container());
    expect(route.name, '/**');
  });
}
