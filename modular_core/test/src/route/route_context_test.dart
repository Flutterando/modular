import 'package:modular_core/src/route/custom_route.dart';
import 'package:modular_core/src/route/modular_key.dart';
import 'package:modular_core/src/route/modular_route.dart';
import 'package:modular_core/src/route/route_context.dart';
import 'package:test/test.dart';

void main() {
  final routeContext = ModuleForRoute();
  test('process route maps', () {
    final initial = routeContext.routeMap[const ModularKey(name: '/')]!;
    expect(initial.name, '/');
    expect(initial.parent, '');

    final initial2 = routeContext.routeMap[const ModularKey(name: '/2')]!;
    expect(initial2.name, '/2');
    expect(initial2.parent, '/');

    expect(routeContext.routeMap[const ModularKey(name: '/home')]?.name, '/home');
  });

  test('get module route', () {
    final other = routeContext.routeMap[const ModularKey(name: '/other/')];
    expect(other?.uri.path, '/first');
    expect(other?.bindContextEntries.containsKey(OtherModule), true);
  });
}

class ModuleForRoute extends RouteContext {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/'), children: [
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
