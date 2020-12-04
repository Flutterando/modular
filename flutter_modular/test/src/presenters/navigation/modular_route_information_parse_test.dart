import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/core/errors/errors.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  var parse = ModularRouteInformationParser();

  BuildContext context = Container().createElement();

  group('Single Module | ', () {
    test('should retrive router /', () async {
      final route = await parse.selectRoute('/', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<Container>());
      expect(route.path, '/');
    });

    test('should retrive router /list', () async {
      final route = await parse.selectRoute('/list', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<ListView>());
      expect(route.path, '/list');
    });
    test('should retrive dynamic router /list/:id', () async {
      final route = await parse.selectRoute('/list/2', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, route.args).toString(), '2');
      expect(route.path, '/list/2');
    });
  });

  group('Multi Module | ', () {
    test('should retrive router /mock', () async {
      final route = await parse.selectRoute('/mock', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<SizedBox>());
      expect(route.path, '/mock');
    });

    test('should retrive router /mock/', () async {
      final route = await parse.selectRoute('/mock/', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<SizedBox>());
      expect(route.path, '/mock/');
    });

    test('should retrive router /mock/list', () async {
      final route = await parse.selectRoute('/mock/list', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<ListView>());
      expect(route.path, '/mock/list');
    });

    test('should retrive dynamic router /mock/list/:id', () async {
      final route = await parse.selectRoute('/mock/list/3', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, route.args).toString(), '3');
      expect(route.path, '/mock/list/3');
    });
  });

  group('Outlet Module | ', () {
    test('should retrive router /home/tab1', () async {
      final route = await parse.selectRoute('/home/tab1', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<Scaffold>());
      expect(route.path, '/home');
      expect(route.routerOutlet.length, 1);
      expect(route.routerOutlet[0].child!(context, null), isA<TextField>());
      expect(route.routerOutlet[0].path, '/home/tab1');
    });
    test('should retrive router /home/tab2/:id', () async {
      final route = await parse.selectRoute('/home/tab2/3', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<Scaffold>());
      expect(route.path, '/home');
      expect(route.routerOutlet.length, 1);
      expect(
          route.routerOutlet[0].child!(context, route.routerOutlet[0].args)
              .toString(),
          '3');
      expect(route.routerOutlet[0].path, '/home/tab2/3');
    });
    test('should throw error if not exist route /home/tab3', () async {
      expect(parse.selectRoute('/home/tab3', ModuleMock()),
          throwsA(isA<ModularError>()));
    });
  });

  test('should resolve Outlet Module Path', () async {
    expect(parse.resolveOutletModulePath('/home', '/'), '/home');
  });
}

class ModuleMock extends ChildModule {
  @override
  List<Bind> binds = [
    Bind((i) => "Test"),
    Bind((i) => true, lazy: false),
    Bind((i) => StreamController(), lazy: false),
    Bind((i) => ValueNotifier(0), lazy: false),
  ];

  @override
  List<ModularRouter> routers = [
    ModularRouter(
      '/',
      child: (context, args) => Container(),
    ),
    ModularRouter(
      '/home',
      child: (context, args) => Scaffold(),
      children: [
        ModularRouter('/tab1', child: (context, args) => TextField()),
        ModularRouter(
          '/tab2/:id',
          child: (context, args) => CustomWidget(
            text: args?.params!['id'],
          ),
        ),
      ],
    ),
    ModularRouter(
      '/mock',
      module: ModuleMock2(),
    ),
    ModularRouter(
      '/list',
      child: (context, args) => ListView(),
    ),
    ModularRouter(
      '/list/:id',
      child: (context, args) => CustomWidget(
        text: args?.params!['id'],
      ),
    ),
  ];
}

class ModuleMock2 extends ChildModule {
  @override
  List<Bind> binds = [
    Bind((i) => "Test"),
    Bind((i) => true, lazy: false),
    Bind((i) => StreamController(), lazy: false),
    Bind((i) => ValueNotifier(0), lazy: false),
  ];

  @override
  List<ModularRouter> routers = [
    ModularRouter(
      '/',
      child: (context, args) => SizedBox(),
    ),
    ModularRouter(
      '/list',
      child: (context, args) => ListView(),
    ),
    ModularRouter(
      '/list/:id',
      child: (context, args) => CustomWidget(
        text: args?.params!['id'],
      ),
    ),
  ];
}

class CustomWidget extends StatelessWidget {
  final String text;

  const CustomWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return text;
  }
}
