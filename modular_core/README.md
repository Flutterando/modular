# modular_core

Injector and Tracker.

## Use Module for Route or Bind(DI) or both.

```dart

class OnlyRouteModule extends Module {
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


class MyModule extends Module {

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
    final route = Tracker.findRoute('/');
    final routeForOnlyRoute = Tracker.findRoute('/only/');
    final route = Tracker.findRoute('/product/1', data: MyArgs());

    //get binds
    final controller = Tracker.injector.get<MyController>();

    //finishApp
    ModularTracker.finishApp();
}

```

## Auxiliary classes

- **Middleware** - abstract.
- **RouteGuard** - extends Middleware.
- **ModularRoute** - abstract for create route.
- **Bind** - encapsulate injection.
- **Module** - abstract extends BindContext and RouteContext. 
