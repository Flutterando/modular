---
sidebar_position: 4
---

# Module

A module clusters all rotes and binds relative to an scope or feature of the application and may contain sub modules forming one composition. 
It means that to access a bind, it needs to be in a parent module already started, otherwise, the bind will not be visible to be recovered using a system of injection. 
Module’s lifetime ends when the last page is closed.

## The ModuleRoute

It is a kind of **ModularRoute** and contains some properties existing in **ChildRoute** such as *transition*, *customTransition*, *duration* and *guards*.

:::tip TIP

It is important to remember that when adding a property in **ModuleRoute**, ALL the child routes inherited this behavior.
For example, if you add *TransitionType.fadeIn* to the *transition* property, the child routes will also have their *transition* property changed to the same *transition* type.
Although, if you define a property on the child route of a **ModuleRoute**, the child route will ignore its module change and keep the value defined in the child.

:::

In **Modular**, everything is done observing the routes, so let’s create a second module to include using ***ModuleRoute***:

```dart title="lib/main.dart" {23,27-35}
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main(){
  return runApp(ModularApp(module: AppModule(), child: AppWidget()));
}

class AppWidget extends StatelessWidget {
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
    ).modular(); //added by extension 
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

-	We created the **HomeModule** module and added the **HomePage** widget with the **ChildRoute**.
-	Then we added the **HomeModule** to **AppModule** using the **ModuleRoute**.
-	Finally, we merge the **HomeModule** routes into the **AppModule**.

Now, we Will enter into a fundamental issue to understand routing when one module is affiliated with another.

:::danger ATTENTION

It is not allowed to use dynamic routes as the name of a **ModuleRoute**, because it would compromise the semantics and the purpose of this kind of route. 
The ending point of a route must always be referenced with **ChildRoute**.

:::

## Routing between modules

The **flutter_modular** works with “named routes”, with segments, query, fragments, very similar to what we see on the web. Let’s look at the anatomy of a “path” to access a route within a submodule, we will need to consider the segments of the route path represented by URI (Uniform Resource Identifier). For example:
```
/home/user/1
```

:::tip TIP

We call “segment” the text separated by `/`. For example, the URI `/home/user/1` has three segment, being them [‘home’, ‘user’, ‘1’];

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

The **BModule** contains another two **ChildRoute** called `/` and `/other`, respectively. 

What would you call **ChildRoute** `/other`? The answer is in follow up. Assuming that AModule is the application’s root module, 
then the initial segment will be the name of the **BModule**, because we need to get a route that is within it.

```
/b-module
```
O próximo segmento será o nome da rota que queremos, a `/other`.

```
/b-module/other
```
READY! When you execute the `Modular.to.navigate(‘/b-module/other’)` the page that will appear will be the **OtherPage()** widget.

The logic is the same when the submodule contains a route named as `/`. Understanding this, we find that the available routes in this example are:
```
/                  =>  APage() 
/b-module/         =>  BPage() 
/b-module/other    =>  OtherPage() 
```

:::tip TIP

When the concatenation of named routes takes place and generates a `//`, this route is normalized to `/`. This explains the first example of the session.

:::

:::tip TIP

If there is a route called `/` in the submodule **flutter_modular** will understand it as “default” route, if no other segment is already placed after the module. For example:

`/b-module`  =>  BPage()

Same as:

`/b-module/` =>  BPage() 

:::

## Relative Vs Absolute paths

When a route path is literally described, then we say it is an absolute path, such as `/foo/bar`. But we can based on the current path and use the notion of POSIX to enter on a route. For example:

Estamos na rota `/foo/bar` e queremos ir para a rota `/foo/baz`. Usando o POSIX, basta
informar **Modular.navigate('./bar')**.

We are on the `/foo/bar` route and we want to go to the `/foo/baz` route. Using POSIX, just inform **Modular.navigate(‘./bar’)**

Note that there is a `./` at the beginning of the path. This causes only the end segment to be swapped.

:::tip TIP

The concept of relative path is applied in terminals, CMD and file import.

Expressions like `../` would replace the penultimate segment onwards.

:::

:::tip TIP

Use the concept of relative routes to optimize navigation between pages in the same module. 
This favors the complete decoupling of the module, as it will not need the previous segments.

:::


## Module import

A module can be created to store only the binds. A use case in this sense would be when we have a Shared or Core Module containing all 
the main binds and distributed among all the modules. To use a module only with binds, we must import it into a module containing routes. See the next example:

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
Note que os binds do **CoreModule** estão marcados com a flag `export: true`, isso significa que o **Bind** pode
ser importado em outro módulo.

Note that **CoreModule** binds are marked with the export flag: true, this means that the bind can be imported into another module.

:::danger ATTENTION

The module import is only for **Binds**. **Routes** will not be imported on this modality.

:::
