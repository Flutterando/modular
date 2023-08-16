---
sidebar_position: 6
---

# Widgets

The **flutter_modular** has widgets to help you develop your smart app.

## WidgetModule

If there's a need to instantiate a module as an application, use the **WidgetModule** to do it.
The injected **Binds** will follow throughout widget's lifecycle, that is, as soon as this widget is
destroyed, the module it represents will also be. Its implementation is very simple:

```dart
class LocalModule extends WidgetModule{
  @override
  List<Bind> get binds => [
    Bind.singleton((i) => MySpecialController())
  ];

  @override
  Widget get view => MyWidget();
}
```

## ModularState

Another way to make a Bind link with the Widget's lifecycle is to implement **ModularState**
in the **State** of a **StatefulWidget**. Thus, Bind will respect the widget's lifecycle, that is,
will be destroyed once the widget is unmounted, even if the module is still active.
**ModularState** also solves dependency and adds 4 getters to the widget: *controller*, *store*,
*bloc* and *cubit*. They all have the same bind instance and use different boilerplate names.

```dart {6}
class HomePage extends StatefulWidget {
    @override
    _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ModularState<HomePage, MyController>{
    ...
}
```

:::danger ATTENTION

**ModularState** should only be used by the feature's main page. If used in an internal widget,
may cause unexpected errors.

:::

## NavigationListener

This widget is actually a *Builder* that rebuilds its scope when there is navigation.
Let's take a look at the **RouterOutlet** example, but implementing the **NavigationListener**
to mark the list item that represents the route as selected:

```dart title="lib/main.dart" {36-56}
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  return runApp(ModularApp(module: AppModule(), child: AppWidget()));
}

class AppWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    Modular.setInitialRoute('/page1');

    return MaterialApp.router(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => HomePage(), children: [
          ChildRoute('/page1', child: (context, args) => InternalPage(title: 'page 1', color: Colors.red)),
          ChildRoute('/page2', child: (context, args) => InternalPage(title: 'page 2', color: Colors.amber)),
          ChildRoute('/page3', child: (context, args) => InternalPage(title: 'page 3', color: Colors.green)),
        ]),
      ];
}

class HomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    final leading = SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: NavigationListener(builder: (context, child) {
        return Column(
          children: [
            ListTile(
              title: Text('Page 1'),
              onTap: () => Modular.to.navigate('/page1'),
              selected: Modular.to.path.endsWith('/page1'),
            ),
            ListTile(
              title: Text('Page 2'),
              onTap: () => Modular.to.navigate('/page2'),
              selected: Modular.to.path.endsWith('/page2'),
            ),
            ListTile(
              title: Text('Page 3'),
              onTap: () => Modular.to.navigate('/page3'),
              selected: Modular.to.path.endsWith('/page3'),
            ),
          ],
        );
      }),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Row(
        children: [
          leading,
          Container(width: 2, color: Colors.black45),
          Expanded(child: RouterOutlet()),
        ],
      ),
    );
  }
}

class InternalPage extends StatelessWidget {
  final String title;
  final Color color;
  const InternalPage({Key? key, required this.title, required this.color}) : super(key: key);

  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Center(child: Text(title)),
    );
  }
}

```

