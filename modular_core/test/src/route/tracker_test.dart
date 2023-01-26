import 'dart:async';

import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  // setPrintResolver(print);
  late Tracker tracker;

  // only coverage
  EmptyModule()
    ..binds
    ..exportedBinds
    ..imports
    ..routes;

  setUp(() {
    tracker = Tracker(AutoInjector(tag: 'Test')..commit());

    final module = MyModule();
    tracker.runApp(module);
  });

  test('thwow error if runApp not iniciate module', () {
    tracker.finishApp();
    expect(() => tracker.module, throwsA(isA<TrackerNotInitiated>()));
  });

  test('setArguments', () {
    final args = ModularArguments.empty();
    tracker.setArguments(args);
    expect(tracker.arguments, args);
  });

  test('dispose instance', () async {
    final route = await tracker.findRoute('/');
    tracker.reportPushRoute(route!);

    expect(tracker.dispose<TestController>(), true);
  });

  test('find route', () async {
    final route = await tracker.findRoute('/') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(tracker.currentPath, '/');
    expect(route?.data, 'first');
  });

  test('find route with params', () async {
    var route = await tracker.findRoute('/product/1') as CustomRoute?;
    expect(route?.uri.path, '/product/1');
    expect(tracker.currentPath, '/product/1');
    expect(tracker.arguments.params['id'], '1');

    route = await tracker.findRoute('/product/test') as CustomRoute?;
    expect(route?.uri.path, '/product/test');
    expect(tracker.currentPath, '/product/test');
    expect(tracker.arguments.params['id'], isNull);
  });

  test('find route with queries', () async {
    var route = await tracker.findRoute('/?q=banana') as CustomRoute?;
    expect(route?.uri.path, '/');
    expect(tracker.arguments.queryParams['q'], 'banana');
  });

  test('find route in other module', () async {
    var route = await tracker.findRoute('/other/') as CustomRoute?;
    expect(route?.uri.path, '/other/');
    expect(route?.data, 'other');
    tracker.reportPopRoute(route!);
  });

  test('find child route in other module', () async {
    var route = await tracker.findRoute('/other/details') as CustomRoute?;
    expect(route?.uri.path, '/other/details');
    expect(route?.parent, '/other/');
    expect(route?.data, 'otherWithDetails');
    tracker.reportPopRoute(route!);
  });

  test('find child route in deep module', () async {
    var route = await tracker.findRoute('/other/internal/') as CustomRoute?;
    expect(route, isNotNull);
    tracker.reportPushRoute(route!);
    expect(route.uri.path, '/other/internal/');
    expect(route.data, 'internal');

    tracker.reportPopRoute(route);

    route = await tracker.findRoute('/other/internal/deep') as CustomRoute?;
    expect(route, isNotNull);
    tracker.reportPushRoute(route!);
    expect(route.uri.path, '/other/internal/deep');
    expect(route.parent, '/other/internal/');
    expect(route.data, 'deep');
    tracker.reportPopRoute(route);
  });

  test('find route with schema', () async {
    expect(await tracker.findRoute('/schema'), isNull);
    final route = await tracker.findRoute('/schema', schema: 'tag') as CustomRoute?;
    expect(route?.uri.path, '/schema');
    expect(route?.data, 'withSchema');
  });

  test('find route with wildcard', () async {
    final route = await tracker.findRoute('/wildcard/test/2') as CustomRoute?;
    expect(route?.uri.path, '/wildcard/test/2');
    expect(route?.data, 'wildcard');
  });

  test('finishApp', () {
    tracker.finishApp();
    expect(() => tracker.module, throwsA(isA<TrackerNotInitiated>()));
  });
}

class MyModule extends Module {
  @override
  final List<Module> imports = [ImportedModule()];

  @override
  final List<Bind> binds = [
    AutoBind.instance<String>('instance'),
    AutoBind.singleton<TestController>(TestController.new),
  ];

  @override
  final List<ModularRoute> routes = [
    CustomRoute('/', data: 'first', middlewares: [
      CustomMidleware()
    ], children: [
      CustomRoute('/second', data: 'second'),
    ]),
    CustomRoute('/schema', data: 'withSchema', schema: 'tag'),
    CustomRoute('/wildcard/**', data: 'wildcard'),
    CustomRoute('/product/:id', data: 'withParams'),
    CustomRoute('/product/test', data: 'test'),
    CustomRoute.moduleMode('/other', module: OtherModule()),
  ];
}

class OtherModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute('/', data: 'other', children: [
          CustomRoute('/details', data: 'otherWithDetails'),
        ]),
        CustomRoute.moduleMode('/internal', module: DeepModule()),
      ];
}

class DeepModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute('/', data: 'internal', children: [
          CustomRoute('/deep', data: 'deep'),
        ]),
      ];
}

class BlockedModule extends Module {
  @override
  List<ModularRoute> get routes => [
        CustomRoute('/'),
        CustomRoute('/again'),
      ];
}

class ImportedModule extends Module {
  @override
  final List<Module> imports = [ImportedModule2()];

  @override
  List<Bind> get exportedBinds => [
        AutoBind.instance<double>(0.0),
      ];
}

class ImportedModule2 extends Module {
  @override
  final List<Bind> exportedBinds = [
    AutoBind.instance<int>(0),
  ];
}

class EmptyModule extends Module {}

class CustomMidleware implements Middleware {
  @override
  FutureOr<ModularRoute?> pre(ModularRoute route) {
    pos(route, '');
    return route;
  }

  @override
  FutureOr<ModularRoute?> pos(route, data) => route;
}

class CustomRoute extends ModularRoute {
  final dynamic data;
  CustomRoute(
    super.name, {
    Uri? uri,
    this.data,
    super.children,
    super.innerModules,
    super.middlewares,
    super.module,
    super.parent,
    super.schema,
  }) : super(uri: uri ?? Uri.parse('/'));

  static CustomRoute moduleMode(String name, {required Module module}) {
    return CustomRoute(name, module: module);
  }

  @override
  ModularRoute addModule(String name, {required Module module}) {
    final innerModules = {module.runtimeType: module};
    return copyWith(
      name: name,
      uri: Uri.parse(name),
      module: module,
      innerModules: innerModules,
    );
  }

  @override
  ModularRoute copyWith({
    String? name,
    String? schema,
    List<ModularRoute>? children,
    List<Middleware>? middlewares,
    Map<Type, Module>? innerModules,
    Uri? uri,
    String? parent,
    Module? module,
  }) {
    return CustomRoute(
      name ?? this.name,
      uri: uri ?? this.uri,
      children: children ?? this.children,
      innerModules: innerModules ?? this.innerModules,
      middlewares: middlewares ?? this.middlewares,
      module: module ?? this.module,
      parent: parent ?? this.parent,
      schema: schema ?? this.schema,
      data: data,
    );
  }
}

class TestController implements Disposable {
  @override
  void dispose() {}
}
