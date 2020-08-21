import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class DynamicModule extends ChildModule {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRouter> get routers => [
        ModularRouter('/', child: (_, __) => Container()),
        ModularRouter('/home', child: (_, __) => Container()),
        ModularRouter('/product', child: (_, __) => Container()),
        ModularRouter('/product/:id', child: (_, __) => Container()),
        ModularRouter('/:id', child: (_, __) => Container()),
      ];
}

main() {
  setUpAll(() {
    Modular.init(DynamicModule());
  });

  group("Dynamic router", () {
    test('Test Get ModularRouter', () {
      var router = Modular.selectRoute("/");
      expect(router.routerName, "/");
    });
    test('Test Get ModularRouter dynamic', () {
      var router = Modular.selectRoute("/1");
      expect(router.routerName, "/:id");
    });
    test('Test Get ModularRouter home', () {
      var router = Modular.selectRoute("/home");
      expect(router.routerName, "/home");
    });

    test('Test Get ModularRouter product', () {
      expect(Modular.selectRoute("/product")?.routerName, "/product");
    });
    test('Test Get ModularRouter product id', () {
      var router = Modular.selectRoute("/product/1");
      expect(router.routerName, "/product/:id");
    });
  });
}
