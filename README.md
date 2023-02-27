<a name="readme-top"></a>

<!--
*** This template was base on othneildrew's Best-README-Template. If you have a suggestion that would make this better, please fork the repo and create a pull request if it's for the template as whole. 

If it's for the Flutterando version of the template just send a message to us (our contacts are below)

*** Don't forget to give his project a star, he deserves it!
*** Thanks for your support! 
-->


  <h1 align="center">Flutter Modular</h1>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://raw.githubusercontent.com/Flutterando/modular/master/flutter_modular.png" alt="Logo" width="170" style=" padding-right: 30px;">
  </a>
  <a href="https://github.com/Flutterando/README-Template/">
    <img src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/logo-flutterando.png" alt="Logo" width="95">
  </a>

  <br />
  <p align="center">
    Welcome to Flutter Modular!
    A smart project structure.
    <br>
    <br>
    <a href="https://modular.flutterando.com.br/docs/intro">View Example</a>
    ·
    <a href="https://github.com/Flutterando/modular/issues">Report Bug</a>
    ·
    <a href="https://github.com/Flutterando/modular/issues">Request Feature</a>
  </p>
</div>

<br>

---


<!-- TABLE OF CONTENTS -->

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <ol>
      <li><a href="#what-is-modular?">What is Modular?</a></li>
      <li><a href="#ready-to-get-started">Ready to get started?</a></li>
      <li><a href="#common-questions">Common questions</a></li>
    </ol>
  </li>
    <li><a href="#usage">Usage</a></li>     
    <ol>
      <li><a href="#starting-a-project">Starting a project</a></li>
      <li><a href="#the-modularApp">The ModularApp</a></li>
      <li><a href="#creating-the-main-module">Creating the Main Module</a></li>
    </ol>
  </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#contributors">Contributors</a></li>
  </ol>
</details>

---

<br>

<!-- ABOUT THE PROJECT -->
## <div id="about-the-project">:memo: About The Project</div>


Let's find out how to implement a Modular structure in your project.

## <div id="what-is-modular?">What is Modular?</div>

Modular proposes to solve two problems:
- Modularized routes.
- Modularized Dependency Injection.

In a monolithic architecture, where we have our entire application as a single module, we design our software in a quick and
elegant way, taking advantage of all the amazing features of Flutter💙. However, producing a larger app in a "monolithic" way
can generate technical debt in both maintanance and scalability. With this in mind, developers adopted architectural strategies to better divide the code, minimizing the negative impacts on the project's maintainability and scalability..

By better dividing the scope of features, we gain:

- Improved understanding of features.
- Less breaking changes.
- Add new non-conflicting features.
- Less blind spots in the project's main business rule.
- Improved developer turnover.

With a more readable code, we extend the life of the project. See example of a standard MVC with 3 features(Auth, Home, Product):

### A typical MVC

    .
    ├── models                                  # All models      
    │   ├── auth_model.dart                     
    │   ├── home_model.dart                     
    │   └── product_model.dart         
    ├── controller                              # All controllers
    │   ├── auth_controller.dart                     
    │   ├── home_controller.dart                     
    │   └── product_controller.dart             
    ├── views                                   # All views
    │   ├── auth_page.dart                     
    │   ├── home_page.dart                     
    │   └── product_page.dart                   
    ├── core                                    # Tools and utilities
    ├── app_widget.dart                         # Main Widget containing MaterialApp 
    └── main.dart                               # runApp 


Here we have a default structure using MVC. This is incredibly useful in almost every application.

Let's see how the structure looks when we divide by scope: 


### Structure divided by scope

    .                  
    ├── features                                 # All features or Modules 
    │   ├─ auth                                  # Auth's MVC       
    │   │  ├── auth_model.dart   
    │   │  ├── auth_controller.dart  
    │   │  └── auth_page.dart                      
    │   ├─ home                                  # Home's MVC       
    │   │  ├── home_model.dart   
    │   │  ├── home_controller.dart  
    │   │  └── home_page.dart                        
    │   └─ product                               # Product's MVC     
    │      ├── product_model.dart   
    │      ├── product_controller.dart
    │      └── product_page.dart                    
    ├── core                                     # Tools and utilities
    ├── app_widget.dart                          # Main Widget containing MaterialApp 
    └── main.dart                                # runApp 



What we did in this structure was to continue using MVC, but this time in scope. This means that
each feature has its own MVC, and this simple approach solves many scalability and maintainability issues.
We call this approach "Smart Structure". But two things were still Global and clashed with the structure itself, so we created Modular to solve this impasse.

In short: Modular is a solution to modularize the route and dependency injection system, making each scope have
its own routes and injections independent of any other factor in the structure.
We create objects to group the Routes and Injections and call them **Modules**.


## Ready to get started?

Modular is not only ingenious for doing something amazing like componentizing Routes and Dependency Injections, it's amazing
for being able to do all this simply!

Go to the next topic and start your journey towards an intelligent structure.

## Common questions

- Does Modular work with any state management approach?
    - Yes, the dependency injection system is agnostic to any kind of class
     including the reactivity that makes up state management.

- Can I use dynamic routes or Wildcards?
    - Yes! The entire route tree responds as on the Web. Therefore, you can use dynamic parameters,
     query, fragments or simply include a wildcard to enable a redirect
     to a 404 page for example.

- Do I need to create a Module for all features?
    - No. You can create a module only when you think it's necessary or when the feature is no longer a part of
    the scope in which it is being worked on.


## <div id="usage">✨ Usage</div>

**flutter_modular** was built using the engine of **modular_core** that's responsible for the dependency injection system and route management. The routing system emulates a tree of modules, just like Flutter does in it's widget trees. Therefore we can add one module inside another one by creating links to the parent module.

## <div id="starting-a-project">Starting a project</div>

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

>**💡 TIP:** Flutter's CLI has a tool that makes package installation easier in the project. Use the command: 
>`(flutter pub add flutter_modular)`

## <div id="the-modularApp">The ModularApp</div>

We need to add a **ModularApp** Widget in the root of our project. MainModule and MainWidget will be created in the next steps, but for now let's change our **main.dart** file:

```dart title="lib/main.dart"

import 'package:flutter/material.dart';

void main(){
  return runApp(ModularApp(module: /*<MainModule>*/, child: /*<MainWidget>*/));
}

```

**ModularApp** forces us to add a main Module and main Widget. What are we going to do next?
This Widget does the initial setup so everything can work as expected. For more details go to **ModularApp** doc.

>**💡 TIP:** It's important that **ModularApp** is the first widget in your app!


## <div id="creating-the-main-module">Creating the Main Module</div>

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

>**💡 TIP:** There are two ModularRoute types: **ChildRoute** and **ModuleRoute**.
 >- **ChildRoute**: Serves to build a Widget.
 >- **ModuleRoute**: Concatenates another module.

<!-- CONTRIBUTING -->
## <div id="contributing">🧑‍💻 Contributing</div>

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the appropriate tag.
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Remember to include a tag, and to follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) and [Semantic Versioning](https://semver.org/) when uploading your commit and/or creating the issue.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## <div id="contact">💬 Contact</div>

Flutterando Community
- [Discord](https://discord.gg/MKPZmtrRb4)
- [Telegram](https://t.me/flutterando)
- [Website](https://www.flutterando.com.br)
- [Youtube Channel](https://www.youtube.com.br/flutterando)
- [Other useful links](https://linktr.ee/flutterando)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<br>

<!-- CONTRIBUTORS -->
## <div id="contributors">👥 Contributors</div>

<a href="https://github.com/Flutterando/modular/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=flutterando/modular" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MANTAINED BY -->
## 🛠️ Maintaned by

<br>

<p align="center">
  <a href="https://www.flutterando.com.br">
    <img width="110px" src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/logo-flutterando.png">
  </a>
  <p align="center">
    This fork version is maintained by <a href="https://www.flutterando.com.br">Flutterando</a>.
  </p>
</p>
