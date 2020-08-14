import 'package:flutter/material.dart' hide Router;

import 'package:flutter_modular/flutter_modular.dart';

import 'package:flutter_test/flutter_test.dart';

class DynamicModule extends ChildModule {
  @override
  List<Bind> get binds => [];

  @override
  List<Router> get routers => [
        Router('/', child: (_, __) => Container()),
        Router('/home', child: (_, __) => Container()),
        Router('/product', child: (_, __) => Container()),
        Router('/product/:id', child: (_, __) => Container()),
        Router('/:id', child: (_, __) => Container()),
      ];
}

main() {
  setUpAll(() {
    Modular.init(DynamicModule());
  });

  group("Dynamic router", () {
    test('Test Get Router', () {
      var router = Modular.selectRoute("/");
      expect(router.routerName, "/");
    });
    test('Test Get Router dynamic', () {
      var router = Modular.selectRoute("/1");
      expect(router.routerName, "/:id");
    });
    test('Test Get Router home', () {
      var router = Modular.selectRoute("/home");
      expect(router.routerName, "/home");
    });

    test('Test Get Router product', () {
      expect(Modular.selectRoute("/product")?.routerName, "/product");
    });
    test('Test Get Router product id', () {
      var router = Modular.selectRoute("/product/1");
      expect(router.routerName, "/product/:id");
    });
  });
}
