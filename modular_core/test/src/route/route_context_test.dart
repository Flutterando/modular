import 'package:modular_core/src/di/bind_context.dart';
import 'package:modular_core/src/route/custom_route.dart';
import 'package:modular_core/src/route/modular_route.dart';
import 'package:modular_core/src/route/route_context.dart';
import 'package:test/test.dart';

void main() {
  final routeContext = ModuleForRoute();
  test('process route maps', () {
    final initial = routeContext.routeMap['/']!;
    expect(initial.name, '/');
    expect(initial.tag, '/');

    final initial2 = routeContext.routeMap['/2']!;
    expect(initial2.name, '/2');
    expect(initial2.tag, '/');

    expect(routeContext.routeMap['/home']?.name, '/home');
  });

  test('get module route', () {
    final other = routeContext.routeMap['/other/'];
    expect(other?.uri.path, '/first');
    expect(other?.bindContextEntries.containsKey(OtherModule), true);
  });
}

class ModuleForRoute extends RouteContext {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/'), children: [
          CustomRoute(name: '/', uri: Uri.parse('/')),
          CustomRoute(name: '/2', uri: Uri.parse('/2')),
        ]),
        CustomRoute(name: '/home', uri: Uri.parse('/home')),
        CustomRoute.module('/other', module: OtherModule())
      ];
}

class OtherModule extends RouteContext {
  @override
  List<ModularRoute> get routes {
    return [
      CustomRoute(name: '/', uri: Uri.parse('/first')),
    ];
  }
}
