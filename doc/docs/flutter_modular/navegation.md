---
sidebar_position: 2
---

# Navegação

No Flutter já temos um poderoso sistema de navegação baseado em pilhas, por isso decidimos adicionar novas funcões sem perder a compatibilidade com a versão atual do SDK. Por tanto, comandos como **pushNamed**, **popUntil** entre outros 
foram presevardos.

## Usando o Modular.to.navigate()

O **flutter_modular** adiciona o comando **navigate** para se aproximar mais da web, substituindo todas as Páginas
pela solicitada. Vamos adicionar mais uma **ChildRoute** ao nosso projeto inicial:

```dart title="lib/main.dart" {24,33-35,42-55}
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
    ).modular(); //added by extension
  }
}

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => HomePage()),
        ChildRoute('/second', child: (context, args) => SecondPage()),
      ];
}

class HomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Modular.to.navigate('/second'),
          child: Text('Navigate to Second Page'),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Modular.to.navigate('/'),
          child: Text('Back to Home'),
        ),
      ),
    );
  }
}
```

Usamos o **Modular.to.navigate()** para uma navegação direta e sem vínculos, isso significa que as rotas anteriores
serão destruidas.

:::tip DICA

Caso queira manter a rota anterior, não utilize o **Modular.to.navigate**, em vez disso use o **Modular.to.pushNamed**, assim poderá usar o **Modular.to.pop** para retornar a rota anterior.

:::



## Passagem de parametros

Comumente temos que enviar dados como parametros a outra página. O **flutter_modular** oferece algumas de fazer isso:

- *Rotas dinâmicas*: Consiste em ter um segmento da rota dinâmico, podendo ser recuperado como um parametro:

```dart
ChildRoute('/second/:name', child: (context, args) => SecondPage(name: args.params['name'])),
```
Adicionamos um segundo segmento ao nome da rota começando com `:`. Essa é uma sintaxe especial para indicar que a rota agora corresponde
a qualquer valor nessa parte do segmento, e esse valor será considerado um parametro, podendo ser recuperado usando `Modular.args`;
```dart
Modular.to.navigate('/second/jacob');  // args.params['name'] -> 'jacob'
Modular.to.navigate('/second/sara');   // args.params['name'] -> 'sara'
Modular.to.navigate('/second/rie');    // args.params['name'] -> 'rie'
```

:::tip DICA

Use *:parameter_name* syntax to provide a parameter in your route.
Route arguments will be available through `args`, and may be accessed in `params` property,
using square brackets notation (['parameter_name']).

:::

- *Query*: Como na web, podemos enviar parametros usando query. Isso não tem o poder de deixar a rota dinâmica, mas tem o mesmo efeito
ao recuperar um parametro;

```dart
ChildRoute('/second', child: (context, args) => SecondPage(name: args.query['name'])),
```
Note que o *name* da rota é o mesmo, então usamos o **Modular.args.query** para pegar o parametro. Vejamos como navegar usando queries:
```dart
Modular.to.navigate('/second?name=jacob');  // args.query['name'] -> 'jacob'
Modular.to.navigate('/second?name=sara');   // args.query['name'] -> 'sara'
Modular.to.navigate('/second?name=rie');    // args.query['name'] -> 'rie'
```

:::tip DICA

Podemos continuar a query separando por `&` assim como na web, como por exemplo: `/second?name=jacob&lastname=moura`.

:::

- *Argumento Direto*: As vezes, precisamos enviar um objeto complexo e não apenas uma String como parametro. Para isso, enviamos o objeto
inteiro direto na navegação:

```dart
class Person {}

// Use Modular.args.data to receive directly argument.
ChildRoute('/second', child: (context, args) => SecondPage(person: args.data)),

// Send object
Modular.to.navigate('/second', arguments: Person());
```


## Adicionando transições

Quando navegamos de uma tela a outra, experimentamos uma transição de tela padrão, mas temos a possiblidade de usar
presets de transições ou criar uma totalmente customizada. 

Tanto o **ChildRoute** quanto o **ModuleRoute** tem a propriedade **Transition**, que recebe um **enum** com presets de animações.
As animações disponíveis são:

```dart
TransitionType.defaultTransition,
TransitionType.fadeIn,
TransitionType.noTransition,
TransitionType.rightToLeft,
TransitionType.leftToRight,
TransitionType.upToDown,
TransitionType.downToUp,
TransitionType.scale,
TransitionType.rotate,
TransitionType.size,
TransitionType.rightToLeftWithFade,
TransitionType.leftToRightWithFade,
TransitionType.custom,
```

Escolha um preset e adicione na propriedade **Transition** de um ModularRoute:

```dart
ChildRoute('/second', child: (context, args) => SecondPage(), transition: TransitionType.fadeIn),
```

:::tip DICA

Você também pode diminuir ou aumentar a duração da transição adicionando a propriedade `duration`.;

:::

Se nenhum preset for útil, podemos criar uma transição customizada usando o `CustomTransition()`:
```dart {4-12}
ChildRoute(
  '/second',
  child: (context, args) => SecondPage(),
  transition: TransitionType.custom,
  customTransition: CustomTransition(
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: child,
      );
    },
  ),
),
```

## RedirectRoute

Se for necessário definir uma rota para redirecionamento, utilize o **RedirectRoute** como rota:
```dart
@override
List<ModularRoute> get routes => [
  ChildRoute('/', child: (context, args) => HomePage()),
  RedirectRoute('/redirect', to: '/'),
];
```
:::tip DICA

**RedirectRoute** é muito útil para trabalhar como um atalho para rotas longas.

:::

## WildcardRoute

Quando uma rota não é encontrada é lançado um erro informando que o caminho da rota não existe. Porém podemos adicionar
um comportamento para quando não for encontrado nenhuma rota no módulo. Chamamos essa rota de **WildcardRoute**:
```dart
WildcardRoute(child: (context, args) => NotFoundPage()),
```


## Guarda de Rotas

Algumas páginas podem conter informações que não podem ser acessiveis a todos os usuários que usam a aplicação, e,
com um App Web, o usuário pode digitar uma url restrita. Para resolver esse problema devemos implementar um **RouteGuard**.

O **ChildRoute** pode receber um ou mais guarda de rotas que interceptam e executam um código de decisão antes que
a página seja lançada. A partir de um **RouteGuard** podemos proibir o acesso a rota ou redirecionar a requisição para
outra página. Vejamos como criar um **RouteGuard**:

```dart
class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: '/login');

  @override
  Future<bool> canActivate(String path, ModularRoute router) {
    return Modular.get<AuthStore>().isLogged;
  }
}
```

Para usar um guard basta adiciona-lo a uma rota:

```dart
ChildRoute('/', child: (context, args) => HomePage(), guards: [AuthGuard()]),
```
:::tip DICA

Definir redirecionamento não é obrigatório, mas caso não haja, será lançado um erro.

:::