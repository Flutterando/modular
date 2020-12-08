import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/core/errors/errors.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
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

    test('should retrive Widcard router when not exist path', () async {
      final route = await parse.selectRoute('/paulo', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<FlutterLogo>());
    });

    test('should guard router /401', () async {
      expect(parse.selectRoute('/401', ModuleMock()),
          throwsA(isA<ModularError>()));
    });
  });

  group('Multi Module | ', () {
    test('should retrive router /mock', () async {
      final route = await parse.selectRoute('/mock', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<SizedBox>());
      expect(route.path, '/mock/');
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

    test('should retrive Widcard router when not exist path', () async {
      final route = await parse.selectRoute('/mock/paulo', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<FlutterLogo>());
    });

    test('should guard router /mock/listguarded', () async {
      expect(parse.selectRoute('/mock/listguarded', ModuleMock()),
          throwsA(isA<ModularError>()));
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

    test('should retrive router  (Module)', () async {
      final route = await parse.selectRoute('/mock/home', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<SizedBox>());
      expect(route.path, '/mock/');
      expect(route.modulePath, '/mock');
      expect(route.routerOutlet.length, 1);
      expect(route.routerOutlet[0].child!(context, null), isA<Container>());
      expect(route.routerOutlet[0].path, '/mock/home');
    });
  });

  test('should resolve Outlet Module Path', () async {
    expect(parse.resolveOutletModulePath('/home', '/'), '/home');
  });
}

class ModuleMock extends ChildModule {
  @override
  final List<Bind> binds = [
    Bind((i) => "Test"),
    Bind((i) => true, lazy: false),
    Bind((i) => StreamController(), lazy: false),
    Bind((i) => ValueNotifier(0), lazy: false),
  ];

  @override
  final List<ModularRouter> routers = [
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
      '/401',
      guards: [MyGuard()],
      child: (context, args) => SingleChildScrollView(),
    ),
    ModularRouter(
      '/list/:id',
      child: (context, args) => CustomWidget(
        text: args?.params!['id'],
      ),
    ),
    ModularRouter('**', child: (context, args) => FlutterLogo())
  ];
}

class ModuleMock2 extends ChildModule {
  @override
  final List<Bind> binds = [
    Bind((i) => "Test"),
    Bind((i) => true, lazy: false),
    Bind((i) => StreamController(), lazy: false),
    Bind((i) => ValueNotifier(0), lazy: false),
  ];

  @override
  final List<ModularRouter> routers = [
    ModularRouter('/', child: (context, args) => SizedBox(), children: [
      ModularRouter('/home', child: (context, args) => Container()),
    ]),
    ModularRouter(
      '/list',
      child: (context, args) => ListView(),
    ),
    ModularRouter(
      '/listguarded',
      guards: [MyGuard()],
      child: (context, args) => ListView(),
    ),
    ModularRouter(
      '/list/:id',
      child: (context, args) => CustomWidget(
        text: args?.params!['id'],
      ),
    ),
    ModularRouter('**', child: (context, args) => FlutterLogo())
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

class MyGuard implements RouteGuard {
  @override
  Future<bool> canActivate(String path, ModularRouter router) async {
    if (path == '/401') {
      return false;
    } else if (path == '/mock/listguarded') {
      return false;
    } else {
      return true;
    }
  }
}
