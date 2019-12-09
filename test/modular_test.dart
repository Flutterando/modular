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
    test('Test Get module sub Router', () {
      expect(Modular.selectRoute("/home/list"), isA<Router>());
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
      var router = Router('/home/list/:id');

      expect(
          Modular.searchRoute(router, "/home/list/1"), true);
      expect(router.params['id'], '1');

      expect(Modular.searchRoute(Router('/home/list'), "/home/list/1"), false);
    });

    test('router with params get', () {
       expect(Modular.selectRoute("/list/1"), isA<Router>());
       expect(Modular.selectRoute("/home/list/1"), isA<Router>());
       expect(Modular.selectRoute("/home/test"), null);
    });
  });
}
