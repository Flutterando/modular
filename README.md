![CI & Coverage](https://github.com/Flutterando/modular/workflows/CI/badge.svg) [![Coverage Status](https://coveralls.io/repos/github/Flutterando/modular/badge.svg?branch=master)](https://coveralls.io/github/Flutterando/modular?branch=master) 
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-17-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

## Flutter Modular

![flutter_modular](https://raw.githubusercontent.com/Flutterando/modular/master/modular.png)

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
  - [Lazy Loading](#lazy-loading)
  - [Unit Test](#unit-test)
  - [DebugMode](#debugmode)

- **[Roadmap](#roadmap)**
- **[Features and bugs](#features-and-bugs)**

## What is Flutter Modular?

Modular proposes a modularized and scalable structure capable of increasing the maintenance capacity, code reusability and memory optimization.

## Modular Structure

Modular structure consists in decoupled and independent modules that will represent the features of the application. 
Each module controls its own dependencies, routes, pages, widgets and business logic. 
As each module has its own folder, you can reuse this module in different projects.

## Modular Pillars

Here are the main focuses of the package:

- Automatic Memory Management.
- Dependency Injection.
- Dynamic Routes Control.
- Modularization of Code.

## Examples

- [Github Search](https://github.com/Flutterando/github_search)

# Getting started with Modular

## Installation

Open pubspec.yaml of your Project and type:

```yaml
dependencies:
    flutter_modular: any
```

or install directly from Git to try out new features and fixes:

```yaml
dependencies:
    flutter_modular:
        git:
            url: https://github.com/Flutterando/modular
```

## Using in a New Project

You need to do some initial setup.

Create a file to be your main widget, set an initial route and use Modular to manage your routing system (app_widget.dart)

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

And to access the route use `Navigator.pushNamed` or `Modular.to.pushNamed`:

```dart
Navigator.pushNamed(context, '/login');
//or
Modular.to.pushNamed('/login');
```

### Current Module Navigation

Use Modular.to for literal paths or Modular.link for routes in current module.

```dart
//Modules home>product
Modular.to.pushNamed('/home/product/list');
Modular.to.pushNamed('/home/product/detail/:id');

//into product module, use Modular.link and navigate between routes of current Module (Product)
Modular.link.pushNamed('/list');
Modular.link.pushNamed('/detail/:id');

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
First create a `RouteGuard`:

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

You can choose which type of animation you want by setting the Router's **transition** parameter using the **TransitionType** enum.

```dart
Router("/product",
        module: AdminModule(),
        transition: TransitionType.fadeIn), //use for change transition
```

If you use transition in a module, all routes in that module will inherit this transition animation.

### Custom Transition Animation Route

You can also use a custom transition animation by setting the Router parameters **transistion** and **customTransition** with **TransitionType.custom** and the **CustomTransition**, respectively.

```dart
Router("/product",
        module: AdminModule(),
        transition: TransitionType.custom,
        customTransition: myCustomTransition),

// ...
```

And, for example, in a custom transitions file declare your custom transitions.

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

## Grouping Routes

You can group routes that contains one(or more) properties in common. 
Properties like **guards**, **transition** and **customTransition** can be for one single route or for a group of routes.

```dart
List<Router> get routers => [
        Router("/", module: HomeModule()),
      ]..addAll(Router.group(guards: [MyGuard()], routes: [
        Router("/admin", module: AdminModule()),
        Router("/profile", module: ProfileModule()),
      ])); // Adiciona as rotas agrupadas ao final da lista
```

Another way of usage with [Sperad Operator](https://dart.dev/guides/language/language-tour#spread-operator) introduced in Dart 2.3:

```dart
List<Router> get routers => [
        Router("/", module: HomeModule()),
        ...Router.group(guards: [MyGuard()],
          transition: TransitionType.rightToLeftWithFade,
          routes: [
            Router("/admin", module: AdminModule()),
            Router("/profile", module: ProfileModule()),
          ]),
      ]; // Mesclar usando
```

## Router Generic Types


You can return values from navigation, like `pop()`.
To achieve this just write the Router object with the value of that return.

```dart
 @override
  List<Router> get routers => [
    //type router with return type
    Router<String>('/event', child: (_, args) => EventPage()),
  ]
```

Now you can write pushNamed and pop

```dart
 String name = await Modular.to.pushNamed<String>();
 //and
 Modular.to.pop('Jacob Moura');
```

## Flutter Web URL Routes(Deeplink-like)

The Routing System can recognizes what's in the website URL and navigate to a part of the application.

Dynamic routes apply here as well:
```
https://flutter-website.com/#/product/1
```
The URL above will open the Product view and args.params ['id']) will be equal to 1.

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

Let's assume that for example we want to retrieve `AppBloc` inside `HomePage`.

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

## Retrieving in view using injection

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

## Consuming a ChangeNotifier Class

Example of a `ChangeNotifier` Class:

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

 you can use the `Consumer` to manage the state of a widget block.

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

## Creating Child Modules

You can create other modules in your project, so instead of inheriting from `MainModule`, you should inherit from `ChildModule`.

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

Consider splitting your code into modules such as `LoginModule`, and into it placing routes related to that module. Maintaining and sharing code in another project will be much easier.

### WidgetModule

The same structure as `ChildModule`. Very useful for modular TabBar visualizations.

```dart
class TabModule extends WidgetModule {

    @override
  List<Bind> get binds => [
    Bind((i) => TabBloc(repository: i.get<TabRepository>())),
    Bind((i) => TabRepository()),
  ];

  Widget get view => TabPage();

}

```

## RouterOutlet

  RouterOutlet is a solution to use another route system totally detached from the Main Navigation.
  This is useful when you need that an element to have its own set of routes even though its inside a page on the main route. A practical example of this is its use in a TabBar or Drawer

``` Dart
PageView(
  controller: controller
  children: [
    RouterOutlet(
      module: Tab1Module()
    ),
    RouterOutlet(
      module: Tab2Module()
    ),
    RouterOutlet(
      module: Tab3Module()
    ),
  ]
),
```

NOTE: Navigation within these modules is made only using Nvigator.of(context) using the routes paths literally.

## Lazy Loading

Another benefit you get when working with modules is to load them "lazily". This means that your dependency injection will only be available when you navigate to a module, and as you exit that module, Modular will wipe memory by removing all injections and executing the dispose() methods (if available) on each module. injected class refers to that module.

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
| Integration with mobx                     |    ✅    |
| Multiple routes                           |    ✅    |
| Pass arguments by route                   |    ✅    |
| Pass url parameters per route             |    ✅    |
| Route Transition Animation                |    ✅    |

## Features and bugs

Please send feature requests and bugs at the issue tracker.

Created from templates made available by Stagehand under a BSD-style license.
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://flutterando.com.br"><img src="https://avatars2.githubusercontent.com/u/4047813?v=4" width="100px;" alt=""/><br /><sub><b>Jacob Moura</b></sub></a><br /><a href="#maintenance-jacobaraujo7" title="Maintenance">🚧</a> <a href="https://github.com/Flutterando/modular/commits?author=jacobaraujo7" title="Code">💻</a> <a href="https://github.com/Flutterando/modular/pulls?q=is%3Apr+reviewed-by%3Ajacobaraujo7" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://www.flutterando.com.br/"><img src="https://avatars1.githubusercontent.com/u/4654514?v=4" width="100px;" alt=""/><br /><sub><b>Vilson Blanco Dauinheimer</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=bwolfs2" title="Code">💻</a> <a href="https://github.com/Flutterando/modular/commits?author=bwolfs2" title="Documentation">📖</a> <a href="https://github.com/Flutterando/modular/pulls?q=is%3Apr+reviewed-by%3Abwolfs2" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://patreon.com/pedromassango"><img src="https://avatars1.githubusercontent.com/u/33294549?v=4" width="100px;" alt=""/><br /><sub><b>Pedro Massango</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=pedromassango" title="Code">💻</a> <a href="https://github.com/Flutterando/modular/commits?author=pedromassango" title="Documentation">📖</a> <a href="#ideas-pedromassango" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://kelvengalvao@gmail.com"><img src="https://avatars3.githubusercontent.com/u/32758755?v=4" width="100px;" alt=""/><br /><sub><b>Kelven I. B. Galvão</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=irvine5k" title="Documentation">📖</a> <a href="#translation-irvine5k" title="Translation">🌍</a></td>
    <td align="center"><a href="http://flutterando.com.br"><img src="https://avatars1.githubusercontent.com/u/16373553?v=4" width="100px;" alt=""/><br /><sub><b>David Araujo</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=davidsdearaujo" title="Code">💻</a></td>
    <td align="center"><a href="https://flutterando.com.br"><img src="https://avatars3.githubusercontent.com/u/41203980?v=4" width="100px;" alt=""/><br /><sub><b>Alvaro Vasconcelos</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=AlvaroVasconcelos" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/andredealmei"><img src="https://avatars3.githubusercontent.com/u/33403972?v=4" width="100px;" alt=""/><br /><sub><b>André de Almeida</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=andredealmei" title="Code">💻</a> <a href="https://github.com/Flutterando/modular/commits?author=andredealmei" title="Documentation">📖</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://medium.com/@albertomonteiro"><img src="https://avatars2.githubusercontent.com/u/836496?v=4" width="100px;" alt=""/><br /><sub><b>Alberto Monteiro</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=AlbertoMonteiro" title="Code">💻</a> <a href="https://github.com/Flutterando/modular/commits?author=AlbertoMonteiro" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/GUIKAR741"><img src="https://avatars2.githubusercontent.com/u/18069622?v=4" width="100px;" alt=""/><br /><sub><b>Guilherme Nepomuceno de Carvalho</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=GUIKAR741" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/lucioeduardo"><img src="https://avatars1.githubusercontent.com/u/14063319?v=4" width="100px;" alt=""/><br /><sub><b>Eduardo Lúcio</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=lucioeduardo" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Ascenio"><img src="https://avatars1.githubusercontent.com/u/7662016?v=4" width="100px;" alt=""/><br /><sub><b>Ascênio</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=Ascenio" title="Code">💻</a> <a href="https://github.com/Flutterando/modular/commits?author=Ascenio" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/wemersonrv"><img src="https://avatars3.githubusercontent.com/u/2028673?v=4" width="100px;" alt=""/><br /><sub><b>Wemerson Couto Guimarães</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=wemersonrv" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/maguro"><img src="https://avatars2.githubusercontent.com/u/165060?v=4" width="100px;" alt=""/><br /><sub><b>Alan D. Cabrera</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=maguro" title="Code">💻</a></td>
    <td align="center"><a href="https://www.linkedin.com/in/jeanluucas/"><img src="https://avatars1.githubusercontent.com/u/6116799?v=4" width="100px;" alt=""/><br /><sub><b>Jean Lucas</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=jeaanlucas" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://www.polygonus.com"><img src="https://avatars1.githubusercontent.com/u/15182027?v=4" width="100px;" alt=""/><br /><sub><b>Moacir Schmidt</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=MoacirSchmidt" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/FelipeMarra"><img src="https://avatars0.githubusercontent.com/u/27727671?v=4" width="100px;" alt=""/><br /><sub><b>Felipe Marra</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=FelipeMarra" title="Documentation">📖</a> <a href="#translation-FelipeMarra" title="Translation">🌍</a></td>
    <td align="center"><a href="https://facebook.com/AdemKouki.Officiel"><img src="https://avatars3.githubusercontent.com/u/12462188?v=4" width="100px;" alt=""/><br /><sub><b>Adem Kouki</b></sub></a><br /><a href="https://github.com/Flutterando/modular/commits?author=Ademking" title="Documentation">📖</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!