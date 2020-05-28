import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'app/app_module.dart';
import 'app/modules/product/product_module.dart';

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
      expect(Modular.prepareToRegex('/home/list/:id'), '/home/list/(.*?)');
      expect(Modular.prepareToRegex('/home/list/:id/'), '/home/list/(.*?)/');
      expect(Modular.prepareToRegex('/home/list/:id/item/:num'),
          '/home/list/(.*?)/item/(.*?)');
    });

    test('search object Router to url', () {
      var router =
          Router('/home/list/:id', child: (_, __) => SizedBox.shrink());

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

    test('modulePath', () {
      Router router = Modular.selectRoute("/home/product/");

      expect(router, isA<Router>());
      expect(router.modulePath, "/home/product");

      router = Modular.selectRoute("/home/product/1");
      expect(router, isA<Router>());
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

    test('Get route correct', () {
      final router = Modular.selectRoute("/prod/product");
      final page = router.child(null, null);
      expect(page, isA<ProductPage>());
    });
  });
}
