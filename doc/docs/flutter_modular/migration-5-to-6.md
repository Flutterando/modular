---
sidebar_position: 8
---

# Migrating from v5 to v6

This part of the documentation will cover techniques for migrating from v5 to v6.

Modular v6 had significant changes only in the modules layer where it refers to the registration of instances and routes. Optimizations were made without the need for BREAK CHANGES in the other layers. 


## Main Widget 

This update is optional but highly recommended as this will be the default for packages that depend on extending Navigator 2.0.

```dart title="v5" {6-7}
class AppWidget extends StatelessWidget {
  Widget build(BuildContext context){
    return MaterialApp.router(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    ); 
  }
}
```

```dart title="v6" {6}
class AppWidget extends StatelessWidget {
  Widget build(BuildContext context){
    return MaterialApp.router(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: Modular.routerConfig,
    ); 
  }
}
```

:::tip TIP

There is a new way to initialize Navigator 2.0 that is up to the developer.

:::


## Modules

Here is where the real work of this migration takes place.
Modules underwent a major change to enable better syntax, testability, and better file readability.

The "getters" responsible for registering routes and binds were changed to methods, each one receiving an object that will help in the register. This way the method becomes "Stateless" allowing better tests of what is being registered.

Let's start by refactoring the routes.
The `routes` method receives the RouteManager instance, and it is this object that will register the routes from now on.


```dart title="v5" 
class AModule extends Module {
  ...
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => APage()),
    ModuleRoute('/b-module', module: BModule()),
  ];
  ...
}
```

```dart title="v6"
class AModule extends Module {
  ...
  @override
  void routes(r) {
    r.child('/', child: (context) => APage());
    r.module('/b-module', module: BModule());
  }
  ...
}
```

:::tip TIP

In **ChildRoute** the **child** property no longer receives the **args** parameter.

:::

The situation is repeated in the registration of **binds**(Instances), which is no longer a getter and becomes a method that receives the Injector object that will be responsible for registering the instances.

```dart title="v5" 
class AModule extends Module {
  ...
  @override
  List<Bind> get binds => [
    Bind.factory((i) => XPTOEmail()),
    Bind.factory((i) => XPTOEmail(i())),
    Bind.singleton((i) => XPTOEmail(i())),
  ];
  ...
}
```

```dart title="v6"
class AModule extends Module {
  ...
  @override
  void binds(i) {
    i.add(XPTOEmail.new);
    i.add<EmailService>(XPTOEmailService.new);
    i.addSingleton(Client.new);
  }
  ...
}
```

:::tip TIP

Thanks to auto_injector it is no longer necessary to put i() as parameters to resolve dependencies. Everything happens automatically now.

:::

In v5, the export declaration of a **Bind** was the responsibility of a flag (**exported**) available in the registry. In v6 this declaration has its own place to improve readability of instances that are registered to be read by other modules via import. 

All records of instances that will be exported must be in the exportedBinds method

```dart title="v5" 
class AModule extends Module {
  ...
  @override
  List<Bind> get binds => [
    Bind.factory((i) => Foo(), exported: true),
  ];
  ...
}
```

```dart title="v6"
class AModule extends Module {
  ...
  @override
  void exportedBinds(i) {
    i.add(Foo.new);
  }
  ...
}
```

:::tip TIP

The getter **Module.imports** used to import binds from another module remains the same.

:::

## Tests

The modular_test package will no longer be needed starting with v6. Consult the testing documentation.