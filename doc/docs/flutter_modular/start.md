---
sidebar_position: 1
---

# Start

The **flutter_modular** was build using the engine of **modular_core**  that's responsible for the dependency injection system and route management. The routing system emulates a tree of modules, just like Flutter does in its widget trees. Because of it, we can add one module inside another by creating paternity links.

## Inspirations from the Angular

The entire **flutter_modular** system came from studies carried out in Angular (another Google framework) and adapted to the world of Flutter. Therefore, there are many similarities between the **flutter_modular** and the Angular Routes and Dependency Injection System.

Routes are reflected in the Application using the features of the new Navigator 2.0, thus allowing the use of multiple nested browsers. We call this feature RouterOutlet, just like in Angular.

As with Angular, each module can be completely independent, so the same module can be used in multiple products. By dividing modules into packages, we can get close to a structure of micro-frontends.


## Starting a project

Our initial goal will be to create an initial app, still without a defined structure or architecture, so that we can study the start components of **flutter_modular**

Create a new Flutter project:
```
flutter create my_smart_app
```

Now add the **flutter_modular** to pubspec.yaml:
```yaml

dependencies:
  flutter_modular: any

```

If all goes well, then we are ready to move on!

:::tip TIP

Flutter's CLI has a tool that facilitates the inclusion of packages in the project. Use the command:

`flutter pub add flutter_modular`

:::

## The ModularApp

We need to add the ModularApp Widget to the root of our project. Let's change our **main.dart** file:

```dart title="lib/main.dart"

import 'package:flutter/material.dart';

void main(){
  return runApp(ModularApp(module: <MainModule>, child: <MainWidget>));
}

```

**ModularApp** forces us to add a main Module and the Main Widget. What are we going to do next?
This Widget does the initial setup so that everything works fine. For more details go to **ModularApp** doc.

:::tip TIP

It's important that **ModularApp** is the first widget in your app!

:::

## Creating the Main Module

A module represents the agglomeration of Routes and Binds.
- **ROUTE**: Page setup eligible for navigation.
- **BIND**: Represents an object that will be available for injection to other dependencies.

We'll talk more about the front.

We can have several modules, but for noew, let's create a main module called **AppModule**:

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
With this we have a routes and injections mechanism separate from the application and can be applied both in a global context (as we are doing) and in a local context, for example, creating a module containing only the binds and routes of a specific feature!

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

We created a Widget called **HomePage** and added its instance in a route called **ChildRoute**.

:::tip TIP

There are two types of ModularRoute, **ChildRoute** and **ModuleRoute**.

**ChildRoute** serve to build a Widget while **ModuleRoute** concatenates another module.

:::

## Creating the Main Widget

The main Widget's function is to instantiate the MaterialApp or CupertinoApp.   
In these main Widgets it is also necessary to configure the custom route system. For this, the **flutter_modular** has an extension that automates this process. For this next code we will use **MaterialApp**, but the process is exactly the same for CupertinoApp.

```dart title="lib/main.dart" {8-15}
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

Here we create a Widget called **AppWidget** containing an instance of **MaterialApp**. Note that in the end, we call the **.modular()** method that was added to **MaterialApp** by extension.

That's enough to run a Modular app. In the next steps let's explore navigation.