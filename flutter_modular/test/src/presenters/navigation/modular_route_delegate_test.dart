import 'package:flutter/material.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_router_delegate.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();

  final delegate = ModularRouterDelegate(parser: ModularRouteInformationParser(), injectMap: {});

  test('should resolve relative path', () {
    expect(delegate.resolverPath('tab2', '/home/tab1'), '/home/tab2');
    expect(delegate.resolverPath('../tab2', '/home/tab1/test'), '/home/tab2');
  });
}
