import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
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
    });

    test('should retrive router /list', () async {
      final route = await parse.selectRoute('/list', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<ListView>());
    });
    test('should retrive dynamic router /list/:id', () async {
      final route = await parse.selectRoute('/list/2', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, route.args).toString(), '2');
    });
  });

  group('Multi Module | ', () {
    test('should retrive router /mock', () async {
      final route = await parse.selectRoute('/mock', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<SizedBox>());
    });

    test('should retrive router /mock/', () async {
      final route = await parse.selectRoute('/mock/', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<SizedBox>());
    });

    test('should retrive router /mock/list', () async {
      final route = await parse.selectRoute('/mock/list', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, null), isA<ListView>());
    });

    test('should retrive dynamic router /mock/list/:id', () async {
      final route = await parse.selectRoute('/mock/list/3', ModuleMock());
      expect(route, isNotNull);
      expect(route.child!(context, route.args).toString(), '3');
    });
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
