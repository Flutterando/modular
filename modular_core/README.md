# modular_core

Injector and Tracker.

## Use Module for Route or Bind(DI) or both.

```dart

class OnlyRouteModule extends RouteContextImpl {
  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/'),
      ];
}

class OnlyBindModule extends Module {
    List<Bind> get binds => [
      Bind.singleton((i) => GlobalController(), export: true),
  ];
}


class MyModule extends RouteContextImpl {

  List<Module> get imports => [OnlyBindModule()];


  List<Bind> get binds => [
      Bind.singleton((i) => MyController(i<GlobalController>())),
  ];

  @override
  List<ModularRoute> get routes => [
        CustomRoute(name: '/'),
        CustomRoute(name: '/product/:id'),
        CustomRoute(name: '/product/test'),
        CustomRoute.module('/only', module: OnlyRouteModule()),
      ];
}


```
### Execute:

```dart 

main(){
    // start module
    ModularTracker.runApp(MyModule());

    //get routes
    final route = ModularTracker.findRoute('/');
    final routeForOnlyRoute = ModularTracker.findRoute('/only/');
    final route = ModularTracker.findRoute('/product/1', data: MyArgs());

    //get binds
    final controller = ModularTracker.injector.get<MyController>().value;

    //finishApp
    ModularTracker.finishApp();
}

```

## Auxiliary classes

- **CustomRoute** - ModularRoute Implementation.
- **ModularRoute** - abstract for create route.
- **Middleware** - abstract.
