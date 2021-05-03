import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/core/errors/errors.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var parse = ModularRouteInformationParser();
  Modular.init(ModuleMock('/redirected'));
  final context = Container().createElement();
  test('Check Route is guarded', () async {
    expect(parse.selectRoute('/guarded', module: ModuleMock()), throwsA(isA<ModularError>()));
  });

  test('Check Route is guarded and redirect', () async {
    final route = await parse.selectRoute('/guarded');
    expect(route.child!(context, ModularArguments()), isA<TextField>());
  });
}

class ModuleMock extends Module {
  final String? guardedRoute;
  ModuleMock([this.guardedRoute]);

  @override
  late final List<ModularRoute> routes = [
    ChildRoute(
      '/guarded',
      child: (context, args) => Container(),
      guards: [MyGuardedRoute()],
      guardedRoute: guardedRoute,
    ),
    ChildRoute(
      '/redirected',
      child: (context, args) => TextField(),
    ),
  ];
}

class MyGuardedRoute implements RouteGuard {
  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    if (path == '/guarded') {
      return false;
    } else {
      return true;
    }
  }
}
