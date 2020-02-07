import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_modular/flutter_modular.dart';

import 'app/app_module.dart';

void main() {
  setUpAll(() {
    Modular.init(AppModule());
  });

  group("Group router", () {
    test('Test Get Router', () {
      expect(Modular.selectRoute("/"), isA<Router>());
    });
    test('Test Get module Router', () {
      expect(Modular.selectRoute("home/"), isA<Router>());
      expect(Modular.selectRoute("/home/"), isA<Router>());
      var router = Modular.selectRoute("/home");
      expect(router.routerName, '/');
    });

    test('router empty', () {
      expect(() => Modular.selectRoute(""), throwsException);
    });

    test('prepare to regex', () {
      expect(Modular.prepareToRegex('/home/list/:id'), '/home/list/(?<id>.*)');
      expect(
          Modular.prepareToRegex('/home/list/:id/'), '/home/list/(?<id>.*)/');
      expect(Modular.prepareToRegex('/home/list/:id/item/:num'),
          '/home/list/(?<id>.*)/item/(?<num>.*)');
    });

    test('search object Router to url', () {
      var router =
          Router('/home/list/:id', child: (_, __) => SizedBox.shrink());

      expect(
          Modular.searchRoute(router, "/home/list/:id", "/home/list/1"), true);
      expect(router.params['id'], "1");

      expect(
          Modular.searchRoute(
              Router('/home/list', child: (_, __) => SizedBox.shrink()),
              "/home/list",
              "/home/list/1"),
          false);
    });

    test('search object Router to url String', () {
      var router =
          Router('/home/list/:id', child: (_, __) => SizedBox.shrink());

      expect(
          Modular.searchRoute(router, "/home/list/:id", "/home/list/01"), true);
      expect(router.params['id'], "01");

      expect(
          Modular.searchRoute(
              Router('/home/list', child: (_, __) => SizedBox.shrink()),
              "/home/list",
              "/home/list/01"),
          false);
    });

    test('router with params get', () {
      expect(Modular.selectRoute("/list/1/2"), isA<Router>());
      expect(Modular.selectRoute("/home/test"), null);
    });
    test('router with params get multiple', () {
      var a = Modular.selectRoute("/home/list/1/2");
      expect(a, isA<Router>());
    });
    test('router with params get multiple 2 modules', () {
      expect(Modular.selectRoute("/home/product/"), isA<Router>());
    });

    test('Convert type', () {
      expect(Modular.convertType("value"), isA<String>());
      expect(Modular.convertType("1"), isA<int>());
      expect(Modular.convertType("1.1"), isA<double>());
      expect(Modular.convertType("true"), isA<bool>());
    });

    test('RouteGuard test', () {
      expect(Modular.selectRoute("/forbidden"), null);
    });
    test('RouteGuard other module', () {
      expect(Modular.selectRoute("/home/forbidden2"), null);
    });

     test('RouteGuard other module Two', () {
      expect(Modular.selectRoute("/homeTwo/forbidden2"), null);
    });
  });
}
