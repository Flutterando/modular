---
sidebar_position: 6
---

# Widgets

The **flutter_modular** has widgets to help you develop your smart app.

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

