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

  - [Example](#example)

- **[Getting started with Modular](#getting-started-with-modular)**

  - [Installation](#installation)
  - [Using in a New Project](#using-in-a-new-project)
  - [Adding Routes](#adding-routes)
  - [Dynamic Routes](#dynamic-routes)
  - [Route Guard](#route-guard)
  - [Route Transition Animation](#route-transition-animation)
  - [Grouping Routes](#grouping-routes)
  - [Flutter Web url Routes](#flutter-web-url-routes)
  - [Dependency Injection](#dependency-injection)
  - [Retrieving in view using injection](#retrieving-in-view-using-injection)

- **[Using Modular widgets to retrieve your classes](#using-modular-widgets-to-retrieve-your-classes)**

  - [ModularState](#modularstate)
  - [Consuming a ChangeNotifier Class](#consuming-a-changenotifier-class)
  - [Creating Child Modules](#creating-child-modules)
  - [WidgetModule](#widgetmodule)
  - [RouterOutlet](#routeroutlet)
  - [RouterOutletList](#routeroutletlist)
  - [Lazy Loading](#lazy-loading)
  - [Unit Test](#unit-test)
  - [Modular test helper](#modular-test-helper)
  - [DebugMode](#debugmode)

- **[Roadmap](#roadmap)**
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
  final List<ModularRoute> routers = [];

  // Provide the root widget associated with your module
  // In this case, it's the widget you created in the first step
  @override
  final Widget bootstrap => AppWidget();
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

The module routes are provided by overriding the `routers`:

```dart
// app_module.dart
class AppModule extends MainModule {

  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [];

  // Provide all the routes for your module
  @override
  final List<ModularRoute>  routers = [
      ModularRoute('/', child: (_, __) => HomePage()),
      ModularRoute('/login', child: (_, __) => LoginPage()),
  ];

  // Provide the root widget associated with your module
  @override
  final Widget bootstrap = AppWidget();
}
```

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
Modular.to.navigate('/home/product/detail/:id');

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
finalList<ModularRoute> routers = [
  ModularRoute(
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
final List<ModularRoute> routers = [
  ModularRoute(
    '/product',
    child: (_, args) => Product(model: args.data),
  ),
];
```

## Route guard

Route guards are middleware-like objects that allow you to control the access of a given route from other route. You can implement a route guard by making a class that `implements RouteGuard`.

For example, the following class will only allow a redirection from `/admin` route:

```dart
class MyGuard implements RouteGuard {
  @override
  bool canActivate(String url, ModularRoute route) {
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
List<ModularRoute> routers = [
  final ModularRoute('/', module: HomeModule()),
  final ModularRoute(
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
ModularRoute('/product',
  module: AdminModule(),
  transition: TransitionType.fadeIn,
), //use for change transition
```

If you use transition in a module, all routes in that module will inherit this transition animation.

### Custom transition animation route

You can also use a custom transition animation by setting the Router parameters `transition` and `customTransition` with `TransitionType.custom` and your `CustomTransition`, respectively:

```dart
ModularRoute('/product',
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

## Route generic types

You can return values from navigation, just like `.pop`.
To achieve this, pass the type you expect to return as type parameter to `Route`:

```dart
@override
final List<ModularRoute> routers => [
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

## Dependency Injection

You can inject any class into your module by overriding the `binds` getter of your module. Typical examples to inject are BLoCs, ChangeNotifier classes or stores(MobX).

A `Bind` object is responsible for configuring the object injection. We have 4 Bind factory types.

```dart
class AppModule extends MainModule {

  // Provide a list of dependencies to inject into your project
  @override
  List<Bind> get binds => [
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


### Retrieving your injected dependencies in the view

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

## Creating child modules

You can create as many modules in your project as you wish, but they will be dependent of the main module. To do so, instead of inheriting from `MainModule`, you should inherit from `ChildModule`:

```dart
class HomeModule extends ChildModule {
  @override
  final List<Bind> binds = [
    Bind.singleton((i) => HomeBloc()),
  ];

  @override
  final List<ModularRoute> routers = [
    ModularRoute('/', child: (_, args) => HomeWidget()),
    ModularRoute('/list', child: (_, args) => ListWidget()),
  ];

}
```

You may then pass the submodule to a `Route` in your main module through the `module` parameter:

```dart
class AppModule extends MainModule {

  @override
  final List<ModularRoute> routers = [
    ModularRoute('/home', module: HomeModule()),
  ];
}
```

We recommend that you split your code in various modules, such as `AuthModule`, and place all the routes related to this module within it. By doing so, it will much easier to maintain and share your code with other projects.

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

Cada ModularRoute pode ter uma lista de ModularRoutes, para que possa ser exibido dentro do ModularRoute pai.
O Widget que reflete essas rotas internas é chamado de `RouterOutlet`.
Você pode ter apenas um `RouterOutlet` por página e ele só é capaz de navegar pelos filhos dessa página.

```dart

  class StartModule extends ChildModule {
      @override
      final List<Bind> binds = [];

      @override
      final List<ModularRoute> routers = [
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

## Unit test

You can use the dependency injection system to replace a `Bind` with a mocked `Bind`, like, for example, a mocked repository. You can also do it using "Inversion of Control" (IoC).

For example, you can make a repository interface (`ILocalStorage`) that satisfies your repository contract requirement and pass it as a paramter type to `Bind`.

```dart
@override
final List<Bind> binds => [
  Bind<ILocalStorage>((i) => LocalStorageSharePreferences()),
];
```

On your test file, you import `flutter_modular_test` and provide your mocked repository in the `initModule` as a replacement of your concrete repository:

```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('change bind', () {
    initModule(AppModule(), changeBinds: [
      Bind<ILocalStorage>((i) => LocalMock()),
    ]);
    expect(Modular.get<ILocalStorage>(), isA<LocalMock>());
  });
}
```
## Modular test helper

Before write in your test file, if you want to improve readability you might to import `flutter_modular_test` and define your mocked module using `IModularTest` and override his methods to create a mock, similar as `ChildModule`, when writing your tests:

The first step is write a class like that:

```dart

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';

class InitAppModuleHelper extends IModularTest {

  final ModularTestType modularTestType;
  IModularTest({this.modularTestType: ModularTestType.resetModule});

  @override
  List<Bind> get binds => [
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
      ];

  @override
  ChildModule get module => AppModule();
  

  @override
  IModularTest get modulardependency => null;

}

```

The right way to use is writing as least one of that per module, its important to remember to put the modular dependecies in `modularDependency`. its useful because when you load this module for testing, all related modules will be load together. In this case the `AppModule` is the root module and it hasn`t dependency.

### Load Modular helper on tests

1. By default when use `IModularTest` each `InitAppModuleHelper().load()` will clean and rebuid the modular and his injects, this is fine to do
each test block independent and make more easy to write modular tests without noise.

```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('change bind', () {
    InitAppModuleHelper().load();
    //do something
  });
  test('change bind', () {
    InitAppModuleHelper().load();
    //do something
  });
}
```

2. To keep previous modular and its injects you can pass the param `modularTestType`.
> **NOTE:** With `modularTestType.keepModulesOnMemory`, it won't clean the modules that already have been loaded. (It doesn't call `Modular.removeModule()`)


```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  
  test('test1', () {
    InitAppModuleHelper().load();
  });

  test('test2', () {
    InitAppModuleHelper(
      modularTestType: ModularTestType.keepModulesOnMemory
      ).load();
      // Keep the same injects loaded by test1
  });
}
```

3. Changing the binds when `load()` the module like `initModule()`.

> **NOTE:** It also can change binds of another modules that are its dependencies until find the MainModule.  

Ex: When you have a tree like `InitAppModuleHelper` <- `InitHomeModuleHelper`, when you call `InitHomeModuleHelper.load(changeBinds:[<newBinds>])` it will be able to change binds on `HomeModule` and `AppModule`. Because of that you only need one changeBinds array and it can make all the changes for you, see it on section: [Create helper for a child module](#create-helper-for-a-child-module).

```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  
  test('test1', () {
    InitAppModuleHelper().load(changeBinds:[
      Bind<ILocalStorage>((i) => LocalStorageHive())

    ]);
  });
  
}
```
### Create helper for a child module
Remember you only need to call the most deeper `IModularTest` and it can load all dependency modules you have added on your mock definition, like the next example:

The first step is define a `IModularTest` to another module, pay attention that the `HomeModule` is a child of `AppModule`, because of that you need to put the `AppModule` on `modularDependency`.

```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/inject/bind.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../app_module_test_modular.dart';
import 'home_module.dart';

class InitHomeModuleHelper extends IModularTest {

  @override
  List<Bind> get binds => [];

  @override
  ChildModule get module => HomeModule();
  
  @override
  IModularTest get modulardependency => InitAppModuleHelper();

}
```

Now we can init the `HomeModule` and all his dependencies just by typing `InitHomeModuleHelper().load()` on your `test_file`. It doesn't matter how deep is your module, all dependencies are recursively loaded in a batch, you only need to create a `IModuleTest` for each one and put your dependencies correctly and it will work fine.

```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'app/modules/home/home_module_test_modular.dart';
main() {
  test('change bind', () {
    InitHomeModuleHelper().load();
    //do something
  });
  test('change bind', () {
    InitHomeModuleHelper().load();
    //do something
  });
}
```

### Mocking with mockito

1. Add the mock into the `binds` list on your `IModularTest` helper, if you dont need to change during the tests.

```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/inject/bind.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mockito/mockito.dart';

import '../../app_module_test_modular.dart';
import 'home_module.dart';

class LocalStorageMock extends Mock implements ILocalStorage {}

class InitHomeModuleHelper extends IModularTest {

  @override
  List<Bind> get binds => [
    Bind<ILocalStorage>((i) => LocalStorageMock()),
  ];

  @override
  ChildModule get module => HomeModule();
  
  @override
  IModularTest get modulardependency => InitAppModuleHelper();
  
}


```

2. Get the instance using `Modular.get()` and change the behavior as you need in the middle of the test:

```dart
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'app/modules/home/home_module_test_modular.dart';

class LocalStorageMock extends Mock implements ILocalStorage {}

main() {

  LocalStorageMock localStorageMock = LocalStorageMock();

  group("IModuleTest", () {
    setUp(() {
      InitAppModuleHelper().load(changeBinds:[
        
        Bind<ILocalStorage>((i) => localStorageMock),

      ]);
      ILocalStorage iLocalStorage = Modular.get<ILocalStorage>();
    });

    test('change bind', () {
      when(localStorageMock.doSomething()).thenReturn("Hello");
      iLocalStorage.doSomething();
      //return Hello

      when(localStorageMock.doSomething()).thenReturn("World");
      iLocalStorage.doSomething();
      //return World
    });

  });

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
