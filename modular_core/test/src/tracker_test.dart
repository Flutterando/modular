import 'dart:async';

import 'package:modular_core/src/route/custom_route.dart';
import 'package:modular_interfaces/modular_interfaces.dart';
import 'package:test/test.dart';
import 'package:modular_core/modular_core.dart';

void main() {
  // setPrintResolver(print);
  Tracker.runApp(MyModule());

  test('thwow error if child has same name of parent', () {
    expect(
        () => CustomRoute(name: '/', data: 'first', children: [
              CustomRoute(name: '/', data: 'second'),
            ]),
        throwsA(isA<AssertionError>()));
  });

  test('find route', () async {
    final route = await Tracker.findRoute('/') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(route?.data, 'first');
  });

  test('find route with params', () async {
    var route = await Tracker.findRoute('/product/1') as CustomRoute?;
    expect(route?.uri.path, '/product/1');
    expect(Tracker.arguments.params['id'], '1');

    route = await Tracker.findRoute('/product/test') as CustomRoute?;
    expect(route?.uri.path, '/product/test');
  });

  test('find route with queries', () async {
    var route = await Tracker.findRoute('/?q=banana') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(Tracker.arguments.queryParams['q'], 'banana');
  });

  test('find route in other module', () async {
    var route = await Tracker.findRoute('/other/') as CustomRoute?;
    expect(route?.uri.path, '/other/');
    expect(route?.data, 'other');
    Tracker.reportPopRoute(route!);
    expect(Tracker.injector.isModuleAlive<OtherModule>(), false);
    expect(Tracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find child route in other module', () async {
    var route = await Tracker.findRoute('/other/details') as CustomRoute?;
    expect(route?.uri.path, '/other/details');
    expect(route?.parent, '/other/');
    expect(route?.data, 'otherWithDetails');
    Tracker.reportPopRoute(route!);
    expect(Tracker.injector.isModuleAlive<OtherModule>(), false);
    expect(Tracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find child route in deep module', () async {
    var route = await Tracker.findRoute('/other/internal/') as CustomRoute?;
    expect(Tracker.injector.isModuleAlive<DeepModule>(), true);
    expect(route?.uri.path, '/other/internal/');
    expect(route?.data, 'internal');

    Tracker.reportPopRoute(route!);
    expect(Tracker.injector.isModuleAlive<DeepModule>(), false);

    route = await Tracker.findRoute('/other/internal/deep') as CustomRoute?;
    expect(Tracker.injector.isModuleAlive<DeepModule>(), true);
    expect(route?.uri.path, '/other/internal/deep');
    expect(route?.parent, '/other/internal/');
    expect(route?.data, 'deep');
    Tracker.reportPopRoute(route!);

    expect(Tracker.injector.isModuleAlive<DeepModule>(), false);
    expect(Tracker.injector.isModuleAlive<OtherModule>(), false);
    expect(Tracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('not access route with guard', () async {
    final futureRoute = Tracker.findRoute('/other/internal/block');
    expect(() async => await futureRoute, throwsA(isA<GuardedRouteException>()));
  });

  test('not access route with guard in module', () async {
    expect(() async => await Tracker.findRoute('/block/'), throwsA(isA<GuardedRouteException>()));
    expect(() async => await Tracker.findRoute('/block/again'), throwsA(isA<GuardedRouteException>()));
  });

  test('find route with schema', () async {
    expect(await Tracker.findRoute('/schema'), isNull);
    final route = await Tracker.findRoute('/schema', schema: 'tag') as CustomRoute?;
    expect(route?.uri.path, '/schema');
    expect(route?.data, 'withSchema');
  });
}

class MyModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', data: 'first', children: [
          CustomRoute(name: '/second', data: 'second'),
        ]),
        CustomRoute(name: '/schema', data: 'withSchema', schema: 'tag'),
        CustomRoute(name: '/product/:id', data: 'withParams'),
        CustomRoute(name: '/product/test', data: 'test'),
        CustomRoute.module('/other', module: OtherModule()),
        CustomRoute.module('/block', module: BlockedModule(), middlewares: [MyGuard()]),
      ];
}

class OtherModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', data: 'other', children: [
          CustomRoute(name: '/details', data: 'otherWithDetails'),
        ]),
        CustomRoute.module('/internal', module: DeepModule()),
      ];
}

class DeepModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', data: 'internal', children: [
          CustomRoute(name: '/deep', data: 'deep'),
        ]),
        CustomRoute(name: '/block', middlewares: [MyGuard()]),
      ];
}

class BlockedModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/'),
        CustomRoute(name: '/again'),
      ];
}

class MyGuard extends RouteGuard {
  @override
  FutureOr<bool> canActivate(String path, ModularRoute router) {
    return false;
  }
}
