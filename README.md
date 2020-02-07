## Flutter Modular 

![](https://raw.githubusercontent.com/Flutterando/modular/master/modular.png)

*Read this in other languages: [English](README.md), [Brazilian Portuguese](README.pt-br.md).*



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
  - [Flutter Web url Routes](#flutter-web-url-routes)
  - [Dependency Injection](#dependency-injection)
  - [Retrieving in view using injection](#retrieving-in-view-using-injection)

- **[Using Modular widgets to retrieve your classes](#using-modular-widgets-to-retrieve-your-classes)**
  
  - [ModularState](#modularstate)
  - [ModuleWidget](#modulewidget)
  - [Consuming a ChangeNotifier Class](#consuming-a-changenotifier-class)
  - [Creating Child Modules](#creating-child-modules)
  - [Lazy Loading](#lazy-loading)
  - [Unit Test](#unit-test)
  - [DebugMode](#debugmode)

- **[Roadmap](#roadmap)**
- **[Features and bugs](#features-and-bugs)**


## What is Flutter Modular?

When a project is getting bigger and more complex, we unfortunately end up joining a lot of archives in just one, it makes harder the code maintenance and reusability too. The Modular give us a bunch of adapted solutions for Flutter, such a dependency injection, routes controller and a "Disposable Singletons" System(When a code provider call automatically dispose and clear the injection).
The Modular came up prepared for adapt to any state management approach to its smart injection system, managing the memory use of your application.


## Modular Structure
Modular gives us a structure that allows us to manage dependency injection and routes in just one file per module, so we can organize our files with that in mind. When all pages, controllers, blocs (and so on) are in a folder and recognized by this main file, we call this a module, as it will provide us with easy maintainability and especially the TOTAL decoupling of code for reuse in other projects.


## Modular Pillars
Here are our main focuses with this package.

- Automatic Memory Management.
- Dependency Injection.
- Dynamic Routes Control.
- Modularization of Code.

## Example

- [Github Search](https://github.com/Flutterando/github_search)

# Getting started with Modular

## Installation

Open pubspec.yaml of your Project and type:

```
dependencies:
    flutter_modular:
```

or install directly from Git to try out new features and fixes:

```
dependencies:
    flutter_modular:
        git:
            url: https://github.com/Flutterando/modular
```

## Using in a New Project 

You need to do some initial setup.

Create a file to be your main widget, thinking of configuring named routes within MaterialApp: (app_widget.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // set your initial route
      initialRoute: "/",
      // add Modular to manage the routing system
      onGenerateRoute: Modular.generateRoute,
    );
  }
}
```

Create a file to be your main module: (app_module.dart)

```dart
// extends from MainModule
class AppModule extends MainModule {

  // here will be any class you want to inject into your project (eg bloc, dependency)
  @override
  List<Bind> get binds => [];

  // here will be the routes of your module
  @override
  List<Router> get routers => [];

// add your main widget here
  @override
  Widget get bootstrap => AppWidget();
}
```

Finish the configuration in your main.dart file to start Modular.

```dart
import 'package:example/app/app_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() => runApp(ModularApp(module: AppModule()));
```
Ready! Your app is already set to Modular!

## Adding Routes
You can add routes to your module using the getter 'routers';

```dart
class AppModule extends MainModule {

 // here will be any class you want to inject into your project (eg bloc, dependency)
  @override
  List<Bind> get binds => [];

 // here will be the routes of your module
  @override
  List<Router> get routers => [
      Router("/", child: (_, args) => HomePage()),
      Router("/login", child: (_, args) => LoginPage()),
  ];

  // add your main widget here  
  @override
  Widget get bootstrap => AppWidget();
}
```

And to access the route use Navigator.pushNamed or Modular.to.pushNamed:

```dart
Navigator.pushNamed(context, '/login');
//or
Modular.to.pushNamed('/login');
```


## Dynamic Routes

You can use the dynamic route system to pass a value per parameter and get it in your view.

```dart

//use (: parameter_name) to use dynamic routes;
//use the args object that is a (ModularArguments) to get the value
 @override
  List<Router> get routers => [
      Router("/product/:id", child: (_, args) => Product(id: args.params['id'])),
  ];

```
A dynamic route is considered valid when the value corresponding to the parameter is filled.
From this you can use:

```dart
 
Navigator.pushNamed(context, '/product/1'); //args.params['id']) gonna be 1
//or
Modular.to.pushNamed('/product/1'); //args.params['id']) gonna be 1

```

You can also pass an object using the "arguments" property in the navigation:

```dart
 
Navigator.pushNamed(context, '/product', arguments: ProductModel()); //args.data
//or
Modular.to.pushNamed('/product', arguments: ProductModel()); //args.data

```
getting on the route

```dart

 @override
  List<Router> get routers => [
      Router("/product", child: (_, args) => Product(model: args.data)),
  ];

```

## Route Guard

We may protect our routes with middleware that will verify that the route is available within a given Route.
First create a RouteGuard:
```dart
class MyGuard implements RouteGuard {
  @override
  bool canActivate(String url) {
    if(url != '/admin'){
      //code of authorization
      return true;
    } else {
      //access denied
      return false
    }
  }
}

```
Now put in the 'guards' property of your Router.

```dart
  @override
  List<Router> get routers => [
        Router("/", module: HomeModule()),
        Router("/admin", module: AdminModule(), guards: [MyGuard()]),
      ];

```

If placed on a module route, RouterGuard will be global to that route.

## Route Transition Animation

You can choose which type of animation you want by setting the Router's ** transition ** parameter using the ** TransitionType ** enum.

```dart
Router("/product", 
        module: AdminModule(),
        transition: TransitionType.fadeIn), //use for change transition
```

If you use transition in a module, all routes in that module will inherit this transition animation.

## Flutter Web url Routes

The Routing System also recognizes what is typed in the website url (flutter web) so what you type in the browser url will open in the app. We hope this makes it easier for Flutter Web sites to make SEO more unique.

Dynamic routes apply here as well:
```
https://flutter-website.com/#/product/1
```
this will open the Product view and args.params ['id']) will be equal to 1.

## Dependency Injection
You can inject any class into your module using getter 'binds', for example classes BLoC, ChangeNotifier or Stores.

Bind is responsible for configuring object injection.


```dart
class AppModule extends MainModule {

 // here will be any class you want to inject into your project (eg bloc, dependency)
  @override
  List<Bind> get binds => [
    Bind((i) => AppBloc()), // using bloc
    Bind((i) => Counter()), // using ChangeNotifier
  ];

// here will be the routes of your module
  @override
  List<Router> get routers => [
      Router("/", child: (_, args) => HomePage()),
      Router("/login", child: (_, args) => LoginPage()),
  ];

// add your main widget here
  @override
  Widget get bootstrap => AppWidget();
}
```

Let's assume that for example we want to retrieve AppBloc inside HomePage.

```dart
//code in bloc
import 'package:flutter_modular/flutter_modular.dart' show Disposable;

// you can extend or implement from Disposable to define a discard for your class, if not.

class AppBloc extends Disposable {

  StreamController controller = StreamController();

  @override
  void dispose() {
    controller.close();
  }
}
```

## Retrieving in view using injection. 
You have some ways to retrieve your injected classes.

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
By default, objects in Bind are singletons and lazy.
When Bind is lazy, the object will only be instantiated when it is called for the first time. You can use 'lazy:false' if you want your object to be instantiated immediately.

```dart
Bind((i) => OtherWidgetNotLazy(), lazy: false),
```
If you do not want the injected object to have a single instance, just use 'singleton: false', this will cause your object to be instantiated every time it is called

```dart
Bind((i) => OtherWidgetNotLazy(), singleton: false),
```



## Using Modular widgets to retrieve your classes


### ModularState


```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends ModularState<MyWidget, HomeController> {

  //variable controller
  //automatic dispose off HomeController

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

### ModuleWidget

The same structure as ChildModule. Very useful for modular TabBar visualizations.

```dart
class TabModule extends ModuleWidget {

    @override
  List<Bind> get binds => [
    Bind((i) => TabBloc(repository: i.get<TabRepository>())),
    Bind((i) => TabRepository()),
  ];

  Widget get view => TabPage();

}

```


## Consuming a ChangeNotifier Class


Example of a ChangeNotifier Class:

```dart
import 'package:flutter/material.dart';

class Counter extends ChangeNotifier {
  int counter = 0;

  increment() {
    counter++;
    notifyListeners();
  }
}
```

 you can use the Consumer to manage the state of a widget block.

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Home"),
      ),
      body: Center(
     // recognize the ChangeNotifier class and rebuild when notifyListeners () is called
        child: Consumer<Counter>(
          builder: (context, value) {
            return Text('Counter ${value.counter}');
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // retrieving the class directly and executing the increment method
          get<Counter>().increment();
        },
      ),
    );
  }
}
```


## Creating Child Modules.

You can create other modules in your project, so instead of inheriting from MainModule, you should inherit from ChildModule.

```dart
class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
    Bind((i) => HomeBloc()),
  ];

  @override
  List<Router> get routers => [
    Router("/", child: (_, args) => HomeWidget()),
    Router("/list", child: (_, args) => ListWidget()),
  ];

  static Inject get to => Inject<HomeModule>.of();

}
```

From this you can call your modules on the main module route.

```dart
class AppModule extends MainModule {

  @override
  List<Router> get routers => [
        Router("/home", module: HomeModule()),
        //...
      ];
}
//...
```

Consider splitting your code into modules such as LoginModule, and into it placing routes related to that module. Maintaining and sharing code in another project will be much easier.

## Lazy Loading

Another benefit you get when working with modules is to load them "lazily". This means that your dependency injection will only be available when you navigate to a module, and as you exit that module, Modular will wipe memory by removing all injections and executing the dispose () methods (if available) on each module. injected class refers to that module.

## Unit Test

You can use the dependency injection system to replace Links from mock links,as an example of a repository. You can also do it using "Inversion of Control"

```dart
@override
  List<Bind> get binds => [
        Bind<ILocalStorage>((i) => LocalStorageSharePreferences()),
      ];
```

We have to import the "flutter_modular_test" to use the methods that will assist with Injection in the test environment.

```dart
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
...

main() {
  test('change bind', () {
    initModule(AppModule(), changeBinds: [
      Bind<ILocalStorage>((i) => LocalMock()), 
    ]);
    expect(Modular.get<ILocalStorage>(), isA<LocalMock>());
  });
}
```

## DebugMode

Remove prints debug:
```dart
Modular.debugMode = false;
```

## Roadmap

This is currently our roadmap, please feel free to request additions/changes.

| Feature                                   | Progress |
| :-----------------------------------------| :------: |
| DI by Module                              |    ✅    |
| Routes by Module                          |    ✅    |
| Widget Consume for ChangeNotifier         |    ✅    |
| Auto-dispose                              |    ✅    |
| Integration with flutter_bloc             |    ✅    |
| Integration with mobx	                    |    ✅    |
| Multiple routes                           |    ✅    |
| Pass arguments by route                   |    ✅    |
| Pass url parameters per route             |    ✅    |
| Route Transition Animation                |    ✅    |

## Features and bugs
Please send feature requests and bugs at the issue tracker.

Created from templates made available by Stagehand under a BSD-style license.
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
