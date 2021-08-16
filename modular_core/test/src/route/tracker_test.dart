import 'package:modular_core/src/route/custom_route.dart';
import 'package:test/test.dart';
import 'package:modular_core/modular_core.dart';

void main() {
  setPrintResolver(print);
  Tracker.runApp(MyModule());

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
}

class MyModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', data: 'first'),
        CustomRoute(name: '/product/:id', data: 'withParams'),
        CustomRoute(name: '/product/test', data: 'test'),
        CustomRoute.module('/other', module: OtherModule()),
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
      ];
}
