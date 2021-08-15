import 'package:test/test.dart';
import 'package:modular_core/modular_core.dart';

import 'route_context_test.dart';

void main() {
  Tracker.runApp(MyModule());

  test('find route', () {
    final route = Tracker.findRoute('/');
    expect(route?.uri.path, '/');
  });
}

class MyModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/')),
      ];
}
