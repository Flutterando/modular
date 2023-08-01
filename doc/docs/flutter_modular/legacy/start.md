---
sidebar_position: 1
---

# Start

**flutter_modular** was built using the engine of **modular_core** that's responsible for the dependency injection system and route management. The routing system emulates a tree of modules, just like Flutter does in it's widget trees. Therefore we can add one module inside another one by creating links to the parent module.

## Inspirations from the Angular

The entire **flutter_modular** system came from studies carried out in Angular (another Google framework) and adapted to the Flutter world. Therefore, there are many similarities between the **flutter_modular** and Angular Routes and Dependency Injection System.

Routes are reflected in the Application using the the new Navigator 2.0 features alongside the use of multiple nested browsers. We call this feature RouterOutlet, just like in Angular.

Each module can be completely independent, so the same module can be used in multiple products. By dividing modules into packages, we can approach a micro-frontend application structure.


## Starting a project

Our first goal will be the creation of a simple app with no defined structure or architecture yet, so that we can study the initial components of **flutter_modular**

Create a new Flutter project:
```
flutter create my_smart_app
```

Now add the **flutter_modular** to pubspec.yaml:
```yaml

dependencies:
  flutter_modular: any

```

If that succeeded, we are ready to move on!

:::tip TIP

Flutter's CLI has a tool that makes package installation easier in the project. Use the command:

`flutter pub add flutter_modular`

:::

## The ModularApp

We need to add a **ModularApp** Widget in the root of our project. MainModule and MainWidget will be created in the next steps, but for now let's change our **main.dart** file:

```dart title="lib/main.dart"

import 'package:flutter/material.dart';

void main(){
  return runApp(ModularApp(module: /*<MainModule>*/, child: /*<MainWidget>*/));
}

```

**ModularApp** forces us to add a main Module and main Widget. What are we going to do next?
This Widget does the initial setup so everything can work as expected. For more details go to **ModularApp** doc.

:::tip TIP

It's important that **ModularApp** is the first widget in your app!

:::

## Creating the Main Module

A module represents a set of Routes and Binds.
- **ROUTE**: Page setup eligible for navigation.
- **BIND**: Represents an object that will be available for injection to other dependencies.

We'll see more info about these topics further below.

We can have several modules, but for now, let's just create a main module called **AppModule**:

```dart title="lib/main.dart" {8-16}
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main(){
  return runApp(ModularApp(module: AppModule(), child: <MainWidget>));
}

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [];
}
```

Note that the module is just a class that inherits from the **Module** class, overriding the **binds** and **routes** properties.
With this we have a route and injection mechanism separate from the application and can be both applied in a global context (as we are doing) or in a local context, for example, creating a module that contains only binds and routes only for a specific feature!

We've added **AppModule** to ModularApp. Now we need an initial route, so let's create a StatelessWidget to serve as the home page.

```dart title="lib/main.dart" {14,18-27}
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main(){
  return runApp(ModularApp(module: AppModule(), child: <MainWidget>));
}

class AppModule extends Module {
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

We've created a Widget called **HomePage** and added its instances in a route called **ChildRoute**.

:::tip TIP

There are two ModularRoute types: **ChildRoute** and **ModuleRoute**.

**ChildRoute**: Serves to build a Widget.
**ModuleRoute**: Concatenates another module.

:::

## Creating the Main Widget

The main Widget's function is to instantiate the MaterialApp or CupertinoApp.

In these main Widgets it's also necessary to set the custom route system. For this next snippet we'll use **MaterialApp**, but the process is exactly the same for CupertinoApp.

```dart title="lib/main.dart" {9-16}
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

Here we create a Widget called **AppWidget** containing an instance of **MaterialApp.router**. 


## Support methods

Navigator 2.0 made Flutter's routing system more dynamic, but some information, previously passed in MaterialApp or CupertinoApp, has been removed, and it will be necessary to configure it using Modular's own support methods.

```dart
Modular.setNavigatorKey(myNavigatorKey);

Modular.setObservers([myObserver]);

Modular.setInitialRoute('/home');
```


That's enough to run a Modular app. In the next steps let's explore navigation.
