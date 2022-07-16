import 'package:modular_core/src/route/custom_route.dart';
import 'package:modular_core/src/route/route_context.dart';
import 'package:modular_interfaces/modular_interfaces.dart';
import 'package:test/test.dart';

void main() {
  final routeContext = ModuleForRoute();

  test('instanciate', () {
    expect(ImplementationTest().routes, const []);
  });

  test('assembleRoute', () {
    final map = routeContext.assembleRoute(CustomRoute(name: '/route'));
    expect(map[ModularKey(name: '/route')]?.name, '/route');
  });

  test('addModule', () {
    var map = routeContext
        .assembleRoute(CustomRoute(name: '/route', context: OtherModule()));
    expect(map[ModularKey(name: '/route/')]?.uri.toString(), '/first');

    map = routeContext.assembleRoute(
        CustomRoute(name: '/route', context: OtherModuleWithlessSlash()));
    expect(map[ModularKey(name: '/route')]?.uri.toString(), isNull);
    expect(map[ModularKey(name: '/route/second')]?.uri.toString(), '/second');
  });

  test('addChildren', () {
    final map = routeContext.addChildren(CustomRoute(name: '/route', children: [
      CustomRoute(name: '/2'),
      CustomRoute(name: '/3'),
      CustomRoute.module('/module', module: OtherModule()),
      CustomRoute(name: '/4', children: [
        CustomRoute(name: '/5'),
        CustomRoute(name: '/6'),
      ]),
    ]));

    expect(map[ModularKey(name: '/route/2')]?.name, '/route/2');
    expect(map[ModularKey(name: '/route/2')]?.parent, '/route');

    expect(map[ModularKey(name: '/route/3')]?.name, '/route/3');
    expect(map[ModularKey(name: '/route/3')]?.parent, '/route');

    expect(map[ModularKey(name: '/route/module/')]?.name, '/route/module/');
    expect(map[ModularKey(name: '/route/module/')]?.parent, '/route');

    expect(map[ModularKey(name: '/route/4')]?.name, '/route/4');
    expect(map[ModularKey(name: '/route/4')]?.parent, '/route');

    expect(map[ModularKey(name: '/route/4/5')]?.name, '/route/4/5');
    expect(map[ModularKey(name: '/route/4/5')]?.parent, '/route/4');

    expect(map[ModularKey(name: '/route/4/6')]?.name, '/route/4/6');
    expect(map[ModularKey(name: '/route/4/6')]?.parent, '/route/4');
  });

  test('order route', () {
    final list = [
      ModularKey(name: '/event/n/**'),
      ModularKey(name: '/:id'),
      ModularKey(name: '/event/**'),
      ModularKey(name: '/**'),
      ModularKey(name: '/route/:id'),
      ModularKey(name: '/route/other'),
      ModularKey(name: '/route/id'),
    ];
    final keys = routeContext.orderRouteKeys(list);
    expect(keys[0].name, '/route/other');
    expect(keys[1].name, '/route/id');
    expect(keys[2].name, '/route/:id');
    expect(keys[3].name, '/:id');
    expect(keys[4].name, '/event/n/**');
    expect(keys[5].name, '/event/**');
    expect(keys[6].name, '/**');
  });
}

class ImplementationTest extends RouteContextImpl {}

class ModuleForRoute extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/'), children: [
          CustomRoute(name: '/2', uri: Uri.parse('/2')),
        ]),
        CustomRoute(name: '/home', uri: Uri.parse('/home')),
        CustomRoute.module('/other', module: OtherModule()),
        CustomRoute(name: '/wildcard/**', uri: Uri.parse('/wildcard')),
      ];
}

class OtherModule extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/', uri: Uri.parse('/first')),
      ];
}

class OtherModuleWithlessSlash extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/second', uri: Uri.parse('/second')),
      ];
}
