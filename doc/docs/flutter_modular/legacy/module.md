---
sidebar_position: 5
---

# Module

A module clusters all routes and binds relative to a scope or feature of the application and may contain sub modules forming one single composition. 
It means that to access a bind, it needs to be in a parent module that's already started, otherwise, the bind will not be visible to be recovered using a system injection.
A Module’s lifetime ends when the last page is closed.

## The ModuleRoute

It is a kind of **ModularRoute** and contains some properties existing in **ChildRoute** such as *transition*, *customTransition*, *duration* and *guards*.

:::tip TIP

It's important to remember that when adding a property in **ModuleRoute**, ALL child routes inherited this behavior.
For example, if you add *TransitionType.fadeIn* to the *transition* property, the child routes will also have their *transition* property changed to the same *transition* type.
Although, if you define a property on the child route of a **ModuleRoute**, the child route will ignore its module change and keep the value defined in the child.

:::

In **Modular**, everything is done observing the routes, so let’s create a second module to include using **ModuleRoute**:

```dart title="lib/main.dart" {23,27-35}
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main(){
  return runApp(ModularApp(module: AppModule(), child: AppWidget()));
}

class AppWidget extends StatelessWidget {
  Widget build(BuildContext context){
    return MaterialApp.router(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    ); //added by extension 
  }
}

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
    ModuleRoute('/', module: HomeModule()),
  ];
}

class HomeModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => HomePage()),
  ];
}

class HomePage extends StatelessWidget {
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Text('This is initial page'),
      ),
    );
  }
}
```

What we see here:

-	We created **HomeModule** module and added **HomePage** widget with **ChildRoute**.
-	Then we added **HomeModule** to **AppModule** using **ModuleRoute**.
-	Finally, we merged **HomeModule** routes into **AppModule**.

Now, we'll head into a fundamental issue to understand routing when one module is affiliated to another.

:::danger ATTENTION

It's not allowed to use dynamic routes as the name of a **ModuleRoute**, because it would compromise the semantics and the purpose of this kind of route. 
The ending point of a route must always be referenced with **ChildRoute**.

:::

## Routing between modules

**flutter_modular** works with “named routes”, with segments, query, fragments, very similar to what we see on web. Let’s look at the anatomy of a “path” to access a route within a submodule, we will need to consider the segments of the route path represented by URI (Uniform Resource Identifier). For example:
```
/home/user/1
```

:::tip TIP

We call “segment” the text separated by `/`. For example, the URI `/home/user/1` has three segments, being them [‘home’, ‘user’, ‘1’];

:::

The composition of a route must contain the route’s name (declared in **ModuleRoute**) and then the child route. See the following use case:

```dart
class AModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => APage()),
    ModuleRoute('/b-module', module: BModule()),
  ];
}

class BModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => BPage()),
    ChildRoute('/other', child: (context, args) => OtherPage()),
  ];
}
```
In this scenario, there are two routes in **AModule**, a **ChildRoute** called `/` and a **ModuleRoute** called `/b-module`.

**BModule** contains another two **ChildRoute** called `/` and `/other`, respectively. 

How would you call **ChildRoute** `/other`? The answer is in follow up. Assuming that AModule is the application’s root module, 
then the initial segment will be the name of the **BModule**, because we need to get a route that is within it.

```
/b-module
```
The next segment will be the name of the route we want, the `/other`.

```
/b-module/other
```
DONE! When you execute the `Modular.to.navigate(‘/b-module/other’)` the page that will appear will be **OtherPage()** widget.

The logic is the same when the submodule contains a route named as `/`. Understanding this, we assume that the available routes in this example are:
```
/                  =>  APage() 
/b-module/         =>  BPage() 
/b-module/other    =>  OtherPage() 
```

:::tip TIP

When the concatenation of named routes takes place and generates a `//`, this route is normalized to `/`. This explains the first example in this section.

:::

:::tip TIP

If there is a route called `/` in the submodule **flutter_modular** will understand it as “default” route, if no other segment is already placed after the module. For example:

`/b-module`  =>  BPage()

Same as:

`/b-module/` =>  BPage() 

:::

## Relative Vs Absolute paths

When a route path is literally described, then we say it is an absolute path, such as `/foo/bar`. But we can consider the current path and use the notion of POSIX to enter on a route. For example:

We are on the `/foo/bar` route and we want to go to the `/foo/baz` route. Using POSIX, just inform **Modular.navigate(‘./bar’)**

Note that there is a `./` at the beginning of the path. This causes only the end segment to be swapped.

:::tip TIP

The concept of relative path is applied as in terminals, CMD and file import.

Expressions like `../` would replace the penultimate segment onwards.

:::

:::tip TIP

Use the concept of relative routes to optimize navigation between pages in the same module. 
This favors the complete decoupling of the module, as it will not need the previous segments.

:::

## Module import

A module can be created only to store binds. A use case would be established when we have a Shared or Core Module containing all the main binds and distributed among all modules. To use a module only with binds, we must import it into a module containing routes. See the next example:

```dart {10-13}
class CoreModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.singleton((i) => HttpClient(), export: true),
    Bind.singleton((i) => LocalStorage(), export: true),
  ]
}

class AppModule extends Module {
  @override
  List<Module> get imports => [
    CoreModule(),
  ]

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => HomePage()),
  ];
}
```

Note that **CoreModule** binds are marked with the export flag `export: true`, this means that the bind can be imported into another module.

:::danger ATTENTION

The module import is only for **Binds**. **Routes** won't be imported.

:::

## RouterOutlet Modularization

You could modularizate each item of you **RouterOutlet**. For example:

```dart
class TabModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => SplashPage(),
        ),
        ChildRoute(
          '/tab',
          child: (context, args) => HomePage(),
          children: [
            ModuleRoute('/home', module: Module1()),
            ModuleRoute('/product', module: Module2()),
            ModuleRoute('/config', module: Module3()),
          ],
        ),
      ];
}
```

A issue this can cause is each `Bind` will be linked of life cycle of your own modules

```dart
class Module1 extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton(
          (i) => HomeController(),
        ),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => const HomePage()),
  ];
}
```

When it identify the tab change it will **dispose** whole module, if you need to keep **Bind** life cycle the same of **RouterOutlet** you will need to add parameter `export:  true`. For example

```dart
class Module1 extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton(
          (i) => HomeController(),
          export:  true,
        ),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => const HomePage()),
  ];
}
```

In the **RouterOutlet** module you will need to **override** de getter method `imports` providing the module you will change de lyfe cicle.

```dart
class TabModule extends Module {
  @override
  List<Module> get imports => [
        Module1(),
        Module2(),
        Module3(),
      ];
      
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => SplashPage(),
        ),
        ChildRoute(
          '/tab',
          child: (context, args) => HomePage(),
          children: [
            ModuleRoute('/home', module: Module1()),
            ModuleRoute('/product', module: Module2()),
            ModuleRoute('/config', module: Module3()),
          ],
        ),
      ];
}
```

:::danger ATTENTION
The object that you will `Binds` and want to keep alive can't be in  `ModularState<Widget, Object>`, because this will *dispose* automatically when widget trigger your own *dispose()*
:::
