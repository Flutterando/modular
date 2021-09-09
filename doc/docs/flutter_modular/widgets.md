---
sidebar_position: 5
---

# Widgets

O **flutter_modular** dispõe de widgets para auxiliar no desenvolvimento do seu app inteligente.

## WidgetModule

Se houver a necessidade de instanciar um módulo como aplicativo, use o **WidgetModule** para tal.
Os **Binds** injetados irão respeitar o ciclo de vida desse widget, ou seja, assim que esse widget for
destruido, o módulo que ele representa também será. Sua implementação é bem simples:

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

Outra maneira de fazer um link do Bind com o ciclo de vida do Widget é implementando o **ModularState**
no **State** de um **StatefulWidget**. Assim, o Bind irá respeitar o cíclo de vida do widget, ou seja,
irá ser destruido assim que o widget for desmontado, mesmo que o módulo ainda esteja ativo.
O **ModularState** também já resolve a dependencia e adiciona ao widget 4 getters: *controller*, *store*,
*bloc* e *cubit*. Todos possue a mesma instância do bind e usam nomes diferentes por clichê.

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

O **ModularState** só deve ser utilizado pela página principal da feature. Caso seja usado em um widget interno, 
poderá causar erros inesperados. 

:::

## NavigationListener

Esse widget é na verdade um *Builder* que reconstroe seu escopo quando houver uma navegação.
Vejamos o exemplo do **RouterOutlet**, mas dessa vez implementando o **NavigationListener**
para marcar como selecionado o item da lista que represente a rota:

```dart title="lib/main.dart" {36-56}
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  return runApp(ModularApp(module: AppModule(), child: AppWidget()));
}

class AppWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/page1',
    ).modular();
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

