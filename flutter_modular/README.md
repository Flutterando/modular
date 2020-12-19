![CI & Coverage](https://github.com/Flutterando/modular/workflows/CI/badge.svg) 
[![pub package](https://img.shields.io/pub/v/flutter_modular.svg)](https://pub.dev/packages/flutter_modular) 


<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-23-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

## Flutter Modular

![flutter_modular](https://raw.githubusercontent.com/Flutterando/modular/master/flutter_modular.png)


- **[What is Flutter Modular?](#what-is-flutter-modular)**
- **[Modular Structure](#modular-structure)**
- **[Modular Pillars](#modular-pillars)**

- **[Getting started with Modular](#getting-started-with-modular)**

  - [Installation](#installation)
  - [Using in a New Project](#using-in-a-new-project)
  - [Adding Routes](#adding-routes)
  - [Dynamic Routes](#dynamic-routes)
  - [Route Guard](#route-guard)
  - [Route Transition Animation](#route-transition-animation)
  - [Flutter Web url Routes](#flutter-web-url-routes-deeplink-like)
  - [Dependency Injection](#dependency-injection)
  - [Retrieving your injected dependencies in the view](#retrieving-your-injected-dependencies-in-the-view)

- **[Using Modular widgets to retrieve your class](#using-modular-widgets-to-retrieve-your-class)**

  - [ModularState](#modularstate)
  - [Creating Child Modules](#creating-child-modules)
  - [WidgetModule](#widgetmodule)
  - [RouterOutlet](#routeroutlet)
  - [Mock the navigation system](#mock-the-navigation-system)

- **[Features and bugs](#features-and-bugs)**

## What is Flutter Modular?

As an application project grows and becomes complex, it's hard to keep your code and project structure mantainable and reusable. Modular provides a bunch of Flutter-suiting solutions to deal with this problem, like dependency injection, routing system and the "disposable singleton" system (that is, Modular disposes the injected module automatically as it is out of scope).

Modular's dependency injection system has out-of-the-box support for any state management system, managing your application memory usage.

Modular also supports Dynamic and Relative Routing like in the Web.

## Modular Structure

Modular structure consists in decoupled and independent modules that will represent the features of the application.
Each module is located in its own directory, and controls its own dependencies, routes, pages, widgets and business logic.
Consequently, you can easily detach one module from your project and use it wherever you want.

## Modular Pillars

These are the main aspects that Modular focus on:

- Automatic Memory Management.
- Dependency Injection.
- Dynamic and Relative Routing.
- Code Modularization.


# Getting started with Modular

## Migration Guide: Modular 2.0 to 3.0

[Guide link here!](https://medium.com/flutterando/migration-guide-modular-2-0-to-3-0-24ecf31d5e8b)


## Installation

Open your project's `pubspec.yaml` and add `flutter_modular` as a dependency:

```yaml
dependencies:
  flutter_modular: any
```

## Using in a new project

To use Modular in a new project, you will have to make some initial setup:

1. Create your main widget with a `MaterialApp` and call the ´´´MaterialApp().modular()´´´ method.

```dart
//  app_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
    ).modular();
  }
}
```

2. Create your project main module file extending `MainModule`:

```dart
// app_module.dart
class AppModule extends MainModule {

  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [];

  // Provide all the routes for your module
  @override
  final List<ModularRoute> routes = [];

  // Provide the root widget associated with your module
  // In this case, it's the widget you created in the first step
  @override
  final Widget bootstrap = AppWidget();
}
```

3. In `main.dart` file, wrap the main module in `ModularApp` to initialize it with Modular:

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app/app_module.dart';

void main() => runApp(ModularApp(module: AppModule()));
```

4. Done! Your app is set and ready to work with Modular!


## Adding routes

The module routes are provided by overriding the `routes` property.

```dart
// app_module.dart
class AppModule extends MainModule {

  // Provide all the routes for your module
  @override
  final List<ModularRoute>  routes = [
      ChildRoute('/', child: (_, __) => HomePage()),
      ChildRoute('/login', child: (_, __) => LoginPage()),
  ];

  // Provide the root widget associated with your module
  @override
  final Widget bootstrap = AppWidget();
}
```

> **NOTE:** Use the ChildRoute object to create a simple route.  

To navigate between pages, use `Modular.to.navigate`.

```dart
Modular.to.navigate('/login');
```

You can also stack pages still using old Navigator API.

```dart
Navigator.pushNamed(context, '/login');
```

Alternatively, you can use `Modular.to.pushNamed`, in which you don't have to provide a `BuildContext`:

```dart
Modular.to.pushNamed('/login');
```

### Relative Navigation

You can use Relative Navigation to navigate like web

```dart
// Modules Home → Product
Modular.to.navigate('/home/product/list');
Modular.to.navigate('/home/product/detail/3');

// Relative Navigation inside /home/product/list
Modular.to.navigate('detail/3'); // it's the same as /home/product/detail/3
Modular.to.navigate('../config'); // it's the same as /home/config

```

## Dynamic routes

You can use dynamic routing system to provide parameters to your `Route`:

```dart
// Use :parameter_name syntax to provide a parameter in your route.
// Route arguments will be available through `args`, and may be accessed in `params` property,
// using square brackets notation (['parameter_name']).

@override
final List<ModularRoute> routes = [
  ChildRoute(
    '/product/:id',
    child: (_, args) => Product(id: args.params['id']),
  ),
];
```

The parameter will be pattern-matched when calling the given route. For example:

```dart
// In this case, `args.params['id']` will have the value `1`.
Modular.to.pushNamed('/product/1');
```

This notation, however, is only valid for simple literals. If you want to pass a complex object to your route, provide it in `arguments` parameter:

```dart
Modular.to.pushNamed('/product', arguments: ProductModel());
```

And it will be available in the `args.data` property instead of `args.params`:

```dart
@override
final List<ModularRoute> routes = [
  ChildRoute(
    '/product',
    child: (_, args) => Product(model: args.data),
  ),
];
```

Retrive the arguments from binds directaly too:

```dart

@override
final List<Bind> binds = [
  Bind.singleton((i) => MyController(data: i.args.data)),
];

```

## Route generic types

You can return values from navigation, just like `.pop`.
To achieve this, pass the type you expect to return as type parameter to `Route`:

```dart
@override
final List<ModularRoute> routes = [
  // This router expects to receive a `String` when popped.
  ModularRoute<String>('/event', child: (_, __) => EventPage()),
]
```

Now, use `.pop` as you use with `Navigator.pop`:

```dart
// Push route
String name = await Modular.to.pushNamed<String>();

// And pass the value when popping
Modular.to.pop('banana');
```

## Flutter Web URL routes (Deeplink-like)

The routing system can recognize what is in the URL and navigate to a specific part of the application.
Dynamic routes apply here as well. The following URL, for instance, will open the Product view, with `args.params['id']` set to `1`.

```
https://flutter-website.com/#/product/1
```

As well could use query parameters or fragment:
```
https://flutter-website.com/#/product?id=1
```

## Creating child modules

You can create as many modules in your project as you wish, but they will be dependent of the main module. To do so, instead of inheriting from `MainModule`, you should inherit from `ChildModule`:

```dart
class HomeModule extends ChildModule {
  @override
  final List<Bind> binds = [
    Bind.singleton((i) => HomeBloc()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => HomeWidget()),
    ChildRoute('/list', child: (_, args) => ListWidget()),
  ];

}
```

You may then pass the submodule to a `Route` in your main module through the `module` parameter:

```dart
class AppModule extends MainModule {

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/home', module: HomeModule()),
  ];
}
```

We recommend that you split your code in various modules, such as `AuthModule`, and place all the routes related to this module within it. By doing so, it will much easier to maintain and share your code with other projects.

> **NOTE:** Use the ModuleRoute object to create a Complex Route.  

## Route guard

Route guards are middleware-like objects that allow you to control the access of a given route from other route. You can implement a route guard by making a class that `implements RouteGuard`.

For example, the following class will only allow a redirection from `/admin` route:

```dart
class MyGuard implements RouteGuard {
  @override
  Future<bool> canActivate(String url, ModularRoute route) {
    if (url != '/admin'){
      // Return `true` to allow access
      return true;
    } else {
      // Return `false` to disallow access
      return false
    }
  }
}
```

To use your `RouteGuard` in a route, pass it to the `guards` parameter:

```dart
@override
List<ModularRoute> routes = [
  final ModuleRoute('/', module: HomeModule()),
  final ModuleRoute(
    '/admin',
    module: AdminModule(),
    guards: [MyGuard()],
  ),
];

```

If placed on a module route, `RouterGuard` will be global to that route.

## Route transition animation

You can choose which type of animation do you want to be used on your pages transition by setting the `Route` `transition` parameter, providing a `TransitionType`.

```dart
ModuleRoute('/product',
  module: AdminModule(),
  transition: TransitionType.fadeIn,
), //use for change transition
```

If you use transition in a module, all routes in that module will inherit this transition animation.

### Custom transition animation route

You can also use a custom transition animation by setting the Router parameters `transition` and `customTransition` with `TransitionType.custom` and your `CustomTransition`, respectively:

```dart
ModuleRoute('/product',
  module: AdminModule(),
  transition: TransitionType.custom,
  customTransition: myCustomTransition,
),
```

For example, this is a custom transition that could be declared in a separated file and used in the `customTransition` parameter:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

CustomTransition get myCustomTransition => CustomTransition(
    transitionDuration: Duration(milliseconds: 500),
    transitionBuilder: (context, animation, secondaryAnimation, child){
      return RotationTransition(turns: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Interval(
                0.00,
                0.50,
                curve: Curves.linear,
              ),
            ),
            ),
            child: child,
          ),
        ),
      )
      ;
    },
  );
```

## Dependency Injection

You can inject any class into your module by overriding the `binds` getter of your module. Typical examples to inject are BLoCs, ChangeNotifier classes or stores(MobX).

A `Bind` object is responsible for configuring the object injection. We have 4 Bind factory types.

```dart
class AppModule extends MainModule {

  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [
    Bind((i) => AppBloc()), 
    Bind.factory((i) => AppBloc()),
    Bind.instance(myObject), 
    Bind.singleton((i) => AppBloc()), 
    Bind.lazySingleton((i) => AppBloc()), 
  ];
...
}
```
**factory**: Instantiate the class whenever it gets called.<br>
**instance**: Use a class that has already been instantiated.<br>
**singleton**: Create a Global instance of a class.<br>
**lazySingleton**: Create a Global instance of a class only when it gets called for the first time. <br>
<br><br>


## Retrieving your injected dependencies in the view

Let's assume the following BLoC has been defined and injected in our module (as in the previous example):

```dart
import 'package:flutter_modular/flutter_modular.dart' show Disposable;

// In Modular, `Disposable` classes are automatically disposed when out of the module scope.

class AppBloc extends Disposable {
  final controller = StreamController();

  @override
  void dispose() {
    controller.close();
  }
}
```

There are several ways to retrieve our injected `AppBloc`.

```dart
class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    // You can use the object Inject to retrieve..

    final appBloc = Modular.get<AppBloc>();
    //...
  }
}
```

## Using Modular widgets to retrieve your class

### ModularState

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends ModularState<MyWidget, HomeController> {

  // Variable controller
  // Automatic dispose of HomeController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modular"),
      ),
      body: Center(child: Text("${controller.counter}"),),
    );
  }
}
```

### WidgetModule

`WidgetModule` has the same structure as `MainModule`/`ChildModule`. It is very useful if you want to have a TabBar with modular pages.

```dart
class TabModule extends WidgetModule {

  @override
  final List<Bind> binds => [
    Bind((i) => TabBloc(repository: i())),
    Bind((i) => TabRepository()),
  ];

  final Widget view = TabPage();

}

```

## RouterOutlet

Each ModularRoute can have a list of ModularRoutes, so that it can be displayed within the parent ModularRoute.
The widget that reflects these internal routes is called `RouterOutlet`.
You can only have one `RouterOutlet` per page and it is only able to browse the children of that page.

```dart

  class StartModule extends ChildModule {
      @override
      final List<Bind> binds = [];

      @override
      final List<ModularRoute> routes = [
        ModularRoute(
          '/start',
          child: (context, args) => StartPage(),
          children: [
            ModularRoute('/home', child: (_, __) => HomePage()),
            ModularRoute('/product', child: (_, __) => ProductPage()),
            ModularRoute('/config', child: (_, __) => ConfigPage()),
          ],
        ),
      ];
    }

```

```dart
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RouterOutlet(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (id) {
          if (id == 0) {
            Modular.to.navigate('/start/home');
          } else if (id == 1) {
            Modular.to.navigate('/start/product');
          } else if (id == 2) {
            Modular.to.navigate('/start/config');
          }
        },
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: 'product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }
```

### Mock the navigation system

We though it would be interesting to provide a native way to mock the navigation system when used with `Modular.to` and `Modular.link`. To do this, you may just implement `IModularNavigator` and pass your implementation to `Modular.navigatorDelegate`.

```dart
// Modular.to and Modular.link will be called MyNavigatorMock implements!
Modular.navigatorDelegate = MyNavigatorMock();
```

## Features and bugs

Please send feature requests and bugs at the [issue tracker](https://github.com/Flutterando/modular/issues).

This README was created based on templates made available by Stagehand under a BSD-style [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind are welcome!
