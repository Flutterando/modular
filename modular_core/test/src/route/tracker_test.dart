import 'dart:async';

import 'package:modular_core/src/route/custom_route.dart';
import 'package:test/test.dart';
import 'package:modular_core/modular_core.dart';

void main() {
  // setPrintResolver(print);
  modularTracker.runApp(MyModule());

  test('thwow error if runApp not iniciate module', () {
    final tracker = TrackerImpl(InjectorImpl());
    expect(() => tracker.module, throwsA(isA<TrackerNotInitiated>()));
  });

  test('setArguments', () {
    final args = ModularArguments.empty();
    modularTracker.setArguments(args);
    expect(modularTracker.arguments, args);
  });

  test('find route', () async {
    final route = await modularTracker.findRoute('/') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(route?.data, 'first');
    modularTracker.reassemble();
  });

  test('find route with params', () async {
    var route = await modularTracker.findRoute('/product/1') as CustomRoute?;
    expect(route?.uri.path, '/product/1');
    expect(modularTracker.currentPath, '/product/1');
    expect(modularTracker.arguments.params['id'], '1');

    route = await modularTracker.findRoute('/product/test') as CustomRoute?;
    expect(route?.uri.path, '/product/test');
    expect(modularTracker.currentPath, '/product/test');
    expect(modularTracker.arguments.params['id'], isNull);
  });

  test('find route with queries', () async {
    var route = await modularTracker.findRoute('/?q=banana') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(modularTracker.arguments.queryParams['q'], 'banana');
  });

  test('find route in other module', () async {
    var route = await modularTracker.findRoute('/other/') as CustomRoute?;
    expect(route?.uri.path, '/other/');
    expect(route?.data, 'other');
    modularTracker.reportPopRoute(route!);
    expect(modularTracker.injector.isModuleAlive<OtherModule>(), false);
    expect(modularTracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find child route in other module', () async {
    var route =
        await modularTracker.findRoute('/other/details') as CustomRoute?;
    expect(route?.uri.path, '/other/details');
    expect(route?.parent, '/other/');
    expect(route?.data, 'otherWithDetails');
    modularTracker.reportPopRoute(route!);
    expect(modularTracker.injector.isModuleAlive<OtherModule>(), false);
    expect(modularTracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find child route in deep module', () async {
    var route =
        await modularTracker.findRoute('/other/internal/') as CustomRoute?;
    expect(route, isNotNull);
    modularTracker.reportPushRoute(route!);
    expect(modularTracker.injector.isModuleAlive<DeepModule>(), true);
    expect(route.uri.path, '/other/internal/');
    expect(route.data, 'internal');

    modularTracker.reportPopRoute(route);
    expect(modularTracker.injector.isModuleAlive<DeepModule>(), false);

    route =
        await modularTracker.findRoute('/other/internal/deep') as CustomRoute?;
    expect(route, isNotNull);
    modularTracker.reportPushRoute(route!);
    expect(modularTracker.injector.isModuleAlive<DeepModule>(), true);
    expect(route.uri.path, '/other/internal/deep');
    expect(route.parent, '/other/internal/');
    expect(route.data, 'deep');
    modularTracker.reportPopRoute(route);

    expect(modularTracker.injector.isModuleAlive<DeepModule>(), false);
    expect(modularTracker.injector.isModuleAlive<OtherModule>(), false);
    expect(modularTracker.injector.isModuleAlive<MyModule>(), true);
  });

  test('find route with schema', () async {
    expect(await modularTracker.findRoute('/schema'), isNull);
    final route = await modularTracker.findRoute('/schema', schema: 'tag')
        as CustomRoute?;
    expect(route?.uri.path, '/schema');
    expect(route?.data, 'withSchema');
  });

  test('find route with wildcard', () async {
    final route =
        await modularTracker.findRoute('/wildcard/test/2') as CustomRoute?;
    expect(route?.uri.path, '/wildcard/test/2');
    expect(route?.data, 'wildcard');
  });

  test('finishApp', () {
    modularTracker.finishApp();
    expect(() => modularTracker.module, throwsA(isA<TrackerNotInitiated>()));
  });

  test('cleanTracker executes finishApp', () {
    cleanTracker();
    expect(() => modularTracker.module, throwsA(isA<TrackerNotInitiated>()));
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
        CustomRoute(name: '/wildcard/**', data: 'wildcard'),
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
