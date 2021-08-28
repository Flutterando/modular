import 'dart:async';

import 'package:modular_core/src/route/custom_route.dart';
import 'package:modular_core/src/route/route_context.dart';
import 'package:modular_interfaces/modular_interfaces.dart';
import 'package:test/test.dart';
import 'package:modular_core/modular_core.dart';

void main() {
  // setPrintResolver(print);
  ModularTracker.runApp(MyModule());

  test('thwow error if child has same name of parent', () {
    expect(
        () => CustomRoute(name: '/', data: 'first', children: [
              CustomRoute(name: '/', data: 'second'),
            ]),
        throwsA(isA<AssertionError>()));
  });

  test('thwow error if runApp not iniciate module', () {
    final tracker = TrackerImpl(InjectorImpl());
    expect(() => tracker.module, throwsA(isA<TrackerNotInitiated>()));
  });

  test('find route', () async {
    final route = await ModularTracker.findRoute('/') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(route?.data, 'first');
  });

  test('find route with params', () async {
    var route = await ModularTracker.findRoute('/product/1') as CustomRoute?;
    expect(route?.uri.path, '/product/1');
    expect(ModularTracker.currentPath, '/product/1');
    expect(ModularTracker.arguments.params['id'], '1');

    route = await ModularTracker.findRoute('/product/test') as CustomRoute?;
    expect(route?.uri.path, '/product/test');
  });

  test('find route with queries', () async {
    var route = await ModularTracker.findRoute('/?q=banana') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(ModularTracker.arguments.queryParams['q'], 'banana');
  });

  test('find route in other module', () async {
    var route = await ModularTracker.findRoute('/other/') as CustomRoute?;
    expect(route?.uri.path, '/other/');
    expect(route?.data, 'other');
    ModularTracker.reportPopRoute(route!);
    expect(ModularTracker.injector.isModuleAlive<OtherModule>(), false);
    expect(ModularTracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find child route in other module', () async {
    var route = await ModularTracker.findRoute('/other/details') as CustomRoute?;
    expect(route?.uri.path, '/other/details');
    expect(route?.parent, '/other/');
    expect(route?.data, 'otherWithDetails');
    ModularTracker.reportPopRoute(route!);
    expect(ModularTracker.injector.isModuleAlive<OtherModule>(), false);
    expect(ModularTracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find child route in deep module', () async {
    var route = await ModularTracker.findRoute('/other/internal/') as CustomRoute?;
    expect(ModularTracker.injector.isModuleAlive<DeepModule>(), true);
    expect(route?.uri.path, '/other/internal/');
    expect(route?.data, 'internal');

    ModularTracker.reportPopRoute(route!);
    expect(ModularTracker.injector.isModuleAlive<DeepModule>(), false);

    route = await ModularTracker.findRoute('/other/internal/deep') as CustomRoute?;
    expect(ModularTracker.injector.isModuleAlive<DeepModule>(), true);
    expect(route?.uri.path, '/other/internal/deep');
    expect(route?.parent, '/other/internal/');
    expect(route?.data, 'deep');
    ModularTracker.reportPopRoute(route!);

    expect(ModularTracker.injector.isModuleAlive<DeepModule>(), false);
    expect(ModularTracker.injector.isModuleAlive<OtherModule>(), false);
    expect(ModularTracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find route with schema', () async {
    expect(await ModularTracker.findRoute('/schema'), isNull);
    final route = await ModularTracker.findRoute('/schema', schema: 'tag') as CustomRoute?;
    expect(route?.uri.path, '/schema');
    expect(route?.data, 'withSchema');
  });

  test('finishApp', () async {
    ModularTracker.finishApp();
    expect(() => ModularTracker.module, throwsA(isA<TrackerNotInitiated>()));
  });
}

class MyModule extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', data: 'first', middlewares: [
          CustomMidleware()
        ], children: [
          CustomRoute(name: '/second', data: 'second'),
        ]),
        CustomRoute(name: '/schema', data: 'withSchema', schema: 'tag'),
        CustomRoute(name: '/product/:id', data: 'withParams'),
        CustomRoute(name: '/product/test', data: 'test'),
        CustomRoute.module('/other', module: OtherModule()),
      ];
}

class OtherModule extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', data: 'other', children: [
          CustomRoute(name: '/details', data: 'otherWithDetails'),
        ]),
        CustomRoute.module('/internal', module: DeepModule()),
      ];
}

class DeepModule extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', data: 'internal', children: [
          CustomRoute(name: '/deep', data: 'deep'),
        ]),
      ];
}

class BlockedModule extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/'),
        CustomRoute(name: '/again'),
      ];
}

class CustomMidleware implements Middleware {
  @override
  FutureOr<ModularRoute?> pre(ModularRoute route) {
    pos(route, '');
    return route;
  }

  @override
  FutureOr<ModularRoute?> pos(route, data) => route;
}
