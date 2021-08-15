import 'package:modular_core/src/di/bind_context.dart';
import 'package:modular_core/src/route/route.dart';
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
  List<Route> get routes => [
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
  List<Route> get routes {
    return [
      CustomRoute(name: '/', uri: Uri.parse('/first')),
    ];
  }
}

class CustomRoute extends Route {
  CustomRoute({
    required String name,
    String tag = '',
    List<Route> children = const [],
    required Uri uri,
    Map<String, Route>? routeMap,
    Route? parent,
    Map<Type, BindContext> bindContextEntries = const {},
  }) : super(
          name: name,
          tag: tag,
          children: children,
          uri: uri,
          parent: parent,
          routeMap: routeMap,
          bindContextEntries: bindContextEntries,
        );

  factory CustomRoute.module(String name, {required RouteContext module}) {
    final bindContextEntries = {module.runtimeType: module};
    final routeMap = module.routeMap.map<String, Route>(
      (key, route) => MapEntry(
        name + key,
        route.copyWith(name: '$name${route.name}', bindContextEntries: bindContextEntries),
      ),
    );
    return CustomRoute(
      name: name,
      uri: Uri.parse(name),
      bindContextEntries: bindContextEntries,
      routeMap: routeMap,
    );
  }

  @override
  Route copyWith({
    String? name,
    String? tag,
    List<Route>? children,
    Route? parent,
    Uri? uri,
    Map<String, Route>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  }) {
    return CustomRoute(
      name: name ?? this.name,
      tag: tag ?? this.tag,
      children: children ?? this.children,
      uri: uri ?? this.uri,
      routeMap: routeMap ?? this.routeMap,
      parent: parent ?? this.parent,
      bindContextEntries: bindContextEntries ?? this.bindContextEntries,
    );
  }
}
