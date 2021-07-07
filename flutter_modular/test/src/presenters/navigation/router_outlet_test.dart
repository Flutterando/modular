import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenters/modular_impl.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_router_delegate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final ModularRouterDelegate delegate;
  late final ModularImpl modular;
  final module = ModuleMock();
  final module2 = Module2Mock();
  final context = Container().createElement();

  setUpAll(() {
    delegate = ModularRouterDelegate(parser: ModularRouteInformationParser(), injectMap: {'ModuleMock': module, 'Module2Mock': module2});
    modular = ModularImpl(routerDelegate: delegate, injectMap: {'ModuleMock': module, 'Module2Mock': module2}, flags: ModularFlags());
    modular.init(module);
  });

  test('search normal route', () async {
    modular.to.navigate('/');
    await Future.delayed(Duration(milliseconds: 500));
    expect(modular.to.path, '/');
  });

  test('search route outlet', () async {
    modular.to.navigate('/start/chat');
    await Future.delayed(Duration(milliseconds: 500));
    expect(modular.to.path, '/start/chat');
    final list = delegate.routerOutletPages['/start/'];
    expect(list?.isNotEmpty, true);
    expect(list?.last.router.path, '/start/chat');
  });

  test('search route outlet in other outlet', () async {
    modular.to.navigate('/start/home/tab1');
    await Future.delayed(Duration(milliseconds: 500));
    final list = delegate.routerOutletPages['/start/home'];
    expect(modular.to.path, '/start/home/tab1');
    expect(list?.isNotEmpty, true);
    expect(list?.last.router.path, '/start/home/tab1');
    expect(list?.last.router.child?.call(context, ModularArguments()), isA<Text>());
  });

  test('search route outlet in other outlet - redirect', () async {
    modular.to.navigate('/start/home/tab1');
    await Future.delayed(Duration(milliseconds: 500));
    final list = delegate.routerOutletPages['/start/home'];
    print(list);
    expect(modular.to.path, '/start/home/tab1');
    expect(list?.isNotEmpty, true);
    expect(list?.last.router.path, '/start/home/tab1');
    expect(list?.last.router.child?.call(context, ModularArguments()), isA<Text>());
  });
}

class ModuleMock extends Module {
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (context, args) => Container()),
    ModuleRoute('/start', module: Module2Mock()),
  ];
}

class Module2Mock extends Module {
  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (context, args) => RouterOutlet(),
      children: [
        ChildRoute('/home', child: (context, args) => TextField(), children: [
          ChildRoute('/tab1', child: (context, args) => const Text('tab1')),
          ChildRoute('/tab2', child: (context, args) => const Text('tab2')),
        ]),
        ChildRoute('/chat', child: (context, args) => TextField()),
      ],
    ),
  ];
}
