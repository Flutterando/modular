import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app/app_module.dart';

void main() {
  setUpAll(() {
    Modular.init(AppModule());
  });

  group("Group router", () {
    test('Test Get ModularRouter', () {
      expect(Modular.selectRoute("/"), isA<ModularRouter>());
    });
    test('Test Get module ModularRouter', () {
      expect(Modular.selectRoute("home/"), isA<ModularRouter>());
      expect(Modular.selectRoute("/home/"), isA<ModularRouter>());
      var router = Modular.selectRoute("/home");
      expect(router.routerName, '/');
    });

    test('router empty', () {
      expect(() => Modular.selectRoute(""), throwsException);
    });

    test('prepare to regex', () {
      expect(Modular.prepareToRegex('/home/list/:id'), '/home/list/(.*?)');
      expect(Modular.prepareToRegex('/home/list/:id/'), '/home/list/(.*?)/');
      expect(Modular.prepareToRegex('/home/list/:id/item/:num'),
          '/home/list/(.*?)/item/(.*?)');
    });

    test('search object ModularRouter to url', () {
      var router =
          ModularRouter('/home/list/:id', child: (_, __) => SizedBox.shrink());

      expect(
          Modular.searchRoute(router, "/home/list/:id", "/home/list/1"), true);
      expect(router.params['id'], "1");

      expect(
          Modular.searchRoute(
              router, "/home/list/:id/item/:num", "/home/list/1/item/2"),
          true);
      expect(router.params['id'], "1");
      expect(router.params['num'], "2");

      expect(
          Modular.searchRoute(
              ModularRouter('/home/list', child: (_, __) => SizedBox.shrink()),
              "/home/list",
              "/home/list/1"),
          false);
    });

    test('search object ModularRouter to url String', () {
      var router =
          ModularRouter('/home/list/:id', child: (_, __) => SizedBox.shrink());

      expect(
          Modular.searchRoute(router, "/home/list/:id", "/home/list/01"), true);
      expect(router.params['id'], "01");

      expect(
          Modular.searchRoute(
              ModularRouter('/home/list', child: (_, __) => SizedBox.shrink()),
              "/home/list",
              "/home/list/01"),
          false);
    });

    test('router with params get', () {
      expect(Modular.selectRoute("/list/1/2"), isA<ModularRouter>());
      expect(Modular.selectRoute("/home/test"), null);
    });
    test('router with params get multiple', () {
      var a = Modular.selectRoute("/home/list/1/2");
      expect(a, isA<ModularRouter>());
    });
    test('router with params get multiple 2 modules', () {
      expect(Modular.selectRoute("/home/product/"), isA<ModularRouter>());
    });

    test('modulePath', () {
      var router = Modular.selectRoute("/home/product/");

      expect(router, isA<ModularRouter>());
      expect(router.modulePath, "/home/product");

      router = Modular.selectRoute("/home/product/1");
      expect(router, isA<ModularRouter>());
      expect(router.modulePath, "/home/product");
    });

    test('Convert type', () {
      expect(Modular.convertType("value"), isA<String>());
      expect(Modular.convertType("1"), isA<int>());
      expect(Modular.convertType("1.1"), isA<double>());
      expect(Modular.convertType("true"), isA<bool>());
    });

    test('RouteGuard test', () {
      expect(() => Modular.selectRoute("/forbidden"),
          throwsA(isA<ModularError>()));
    });
    test('RouteGuard other module', () {
      expect(() => Modular.selectRoute("/home/forbidden2"),
          throwsA(isA<ModularError>()));
    });
    test('RouteGuard other module', () {
      expect(() => Modular.selectRoute("/home/forbidden2"),
          throwsA(isA<ModularError>()));
    });

    test('RouteGuard other module Two', () {
      expect(() => Modular.selectRoute("/homeTwo/forbidden2"),
          throwsA(isA<ModularError>()));
    });

    test('RouteGuard other module Two 2', () {
      final router = Modular.selectRoute("/homeTwo2/forbidden2");
      expect(router.routerName, "/forbidden2");
    });
    test('Get route correct', () {
      final router = Modular.selectRoute("/prod/product");
      expect(router.routerName, "/product");
    });
  });
}
