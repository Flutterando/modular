import 'package:modular_core/src/route/custom_route.dart';
import 'package:test/test.dart';
import 'package:modular_core/modular_core.dart';

void main() {
  setPrintResolver(print);
  Tracker.runApp(MyModule());

  test('find route', () {
    final route = Tracker.findRoute('/');
    expect(route?.uri.path, '/');
  });

  test('find route with params', () {
    var route = Tracker.findRoute('/product/1');
    expect(route?.uri.path, '/product/1');
    expect(Tracker.arguments.params['id'], '1');

    route = Tracker.findRoute('/product/test');
    expect(route?.uri.path, '/product/test');
  });

  test('find route with queries', () {
    var route = Tracker.findRoute('/?q=banana');
    expect(route?.uri.path, '/');
    expect(Tracker.arguments.queryParams['q'], 'banana');
  });

  test('find route in other module', () {
    var route = Tracker.findRoute('/other/');
    expect(route?.uri.path, '/other/');
    Tracker.reportPopRoute(route!);
    expect(Tracker.injector.isModuleAlive<OtherModule>(), false);
    expect(Tracker.injector.isModuleAlive<MyModule>(), true);
  });
}

class MyModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/')),
        CustomRoute(name: '/product/:id', uri: Uri.parse('/')),
        CustomRoute(name: '/product/test', uri: Uri.parse('/')),
        CustomRoute.module('/other', module: OtherModule()),
      ];
}

class OtherModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/')),
      ];
}
