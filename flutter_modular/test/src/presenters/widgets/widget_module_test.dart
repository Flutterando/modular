import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('description', () {});
}

class MyWidgetModule extends WidgetModule {
  @override
  final List<Bind<Object>> binds = const [];

  @override
  final Widget view = Container();
}
