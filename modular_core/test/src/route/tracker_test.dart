import 'package:test/test.dart';
import 'package:modular_core/modular_core.dart';

import 'route_context_test.dart';

void main() {
  Tracker.runApp(MyModule());

  test('find route', () {
    final route = Tracker.findRoute('/');
    expect(route?.uri.path, '/');
  });

  test('find route with params', () {
    var route = Tracker.findRoute('/product/1');
    expect(route?.uri.path, '/product/1');
    expect(Tracker.arguments.params['id'], '1');

    route = Tracker.findRoute('/product/1');
    expect(route?.uri.path, '/product/test');
  });
}

class MyModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/')),
        CustomRoute(name: '/product/:id', uri: Uri.parse('/')),
        CustomRoute(name: '/product/test', uri: Uri.parse('/')),
      ];
}
