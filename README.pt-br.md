# Flutter Modular

![](https://raw.githubusercontent.com/Flutterando/modular/master/modular.png)

*Leia em outros idiomas: [Inglês](README.md), [Português](README.pt-br.md).*


## O que é o Flutter Modular?

Quando um projeto vai ficando grande e complexo, acabamos juntando muitos arquivos em um só lugar, isso dificulta a manutenção do código e também o reaproveitamento.
O Modular nos trás várias soluções adaptadas para o Flutter como Injeção de Dependências, Controle de Rotas e o Sistema de "Singleton Descartáveis" que é quando o provedor do código se encarrega de "chamar" o dispose automaticamente e limpar a injeção (prática muito comum no package bloc_pattern).
O Modular vem preparado para adaptar qualquer gerência de estado ao seu sistema de Injeção de Dependências inteligente, gerenciando a memória do seu aplicativo.

## Qual a diferença entre o Flutter Modular e o bloc_pattern;

Aprendemos muito com o bloc_pattern, e entendemos que a comunidade tem diversas preferências com relação a Gerência de Estado, então, até mesmo por uma questão de nomeclatura, decidimos tratar o Modular como uma evolução natural do bloc_pattern, e a partir daí implementar o sistema de Rotas Dinâmicas que ficará muito popular graças ao Flutter Web. Rotas nomeadas são o futuro do Flutter, e estamos nos preparando para isso.

## O bloc_pattern será depreciado?

Não! Continuaremos a dar suporte e melhora-lo. Apesar de que a migração para o Modular será muito simples também.

## Estrutura Modular

O Modular nos traz uma estrutura que permite gerenciar a injeção de dependencias e rotas em apenas um arquivo por módulo, permitindo organizar nossos arquivos a partir desta idéia. Quando todos as paginas, controllers, blocs (e etc..) estiverem em uma pasta e reconhecidos por esse arquivo principal, a isso damos o nome de módulo, pois nos propocionará fácil manutenabilidade e principalmente o desacoplamento TOTAL do código para reaproveitamento em outros projetos.

## Pilares do Modular

Aqui estão nossos focos principais com o package.

- Gerência Automática de Memória.
- Injeção de Dependências.
- Controle de Rotas Dinâmicas.
- Modularização de Código.


## Exemplos

- [Github Search](https://github.com/Flutterando/github_search)


# Começando com o Modular

## Instalação

Abra o pubspec.yaml do seu Projeto e digite:

```
dependencies:
    flutter_modular:
```
ou instale diretamente pelo Git para testar as novas funcionalidades e correções:

```
dependencies:
    flutter_modular:
        git:
            url: https://github.com/Flutterando/modular
```

## Usando em um novo projeto

Você precisa fazer algumas configurações iniciais.

- Crie um arquivo para ser seu Widget principal, pensando na configuração de rotas nomeadas dentro do MaterialApp: (app_widget.dart)

```dart

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //defina sua rota inicial
      initialRoute: "/",
      //adicione o Modular para que ele possa gerenciar o sistema de rotas.
      onGenerateRoute: Modular.generateRoute,
    );
  }
}

```


- Crie um arquivo para ser seu módulo principal: (app_module.dart)

```dart

//herde de MainModule
class AppModule extends MainModule {

  //aqui ficarão todas as classes que deseja Injetar no seu projeto (ex: bloc, dependency)
  @override
  List<Bind> get binds => [];

  //aqui ficarão as rotas do seu módulo
  @override
  List<Router> get routers => [];

  //adicione seu widget principal aqui  
  @override
  Widget get bootstrap => AppWidget();
}


```

- Termine a configuração no seu arquivo main.dart para iniciar o Modular.

```dart
import 'package:example/app/app_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() => runApp(ModularApp(module: AppModule()));
```

Pronto! Seu aplicativo já está configurado para usar o Modular!

## Adicionando Rotas

Você pode adicionar rotas no seu módulo usando o getter 'routers';

```dart
class AppModule extends MainModule {

  //aqui ficarão todas as classes que deseja Injetar no seu projeto (ex: bloc, dependency)
  @override
  List<Bind> get binds => [];

  //aqui ficarão as rotas do seu módulo
  @override
  List<Router> get routers => [
      Router("/", child: (_, args) => HomePage()),
      Router("/login", child: (_, args) => LoginPage()),
  ];

  //adicione seu widget principal aqui  
  @override
  Widget get bootstrap => AppWidget();
}
```

E para acessar a rota use o **Navigator.pushNamed**:
```dart
Navigator.pushNamed(context, '/login');
//or
Modular.to.pushNamed('/login');
```

## Rotas dinâmicas

Você pode usar o sistema de rotas dinâmicas para passar um valor por parâmetro e o receber em sua view.


```dart

//use (:nome_do_parametro) para usar rotas dinâmicas;
//use o objeto args que é um (ModularArguments) para receber o valor
 @override
  List<Router> get routers => [
      Router("/product/:id", child: (_, args) => Product(id: args.params['id'])),
  ];

```
Uma rota dinâmica é considerada válida quando o valor correspontente ao parâmentro é preenchido.
A partir disto você pode usar:

```dart
 
Navigator.pushNamed(context, '/product/1'); //args.params['id']) será 1
//or
Modular.to.pushNamed('/product/1'); //args.params['id']) será 1

```

## Proteção de Rotas

Podemos proteger nossas rotas com middlewares que verificarão se a rota está disponível dentro de um determinado Route.
Primeiro crie um RouteGuard:
```dart
class MyGuard implements RouteGuard {
  @override
  bool canActivate(String url) {
    if(url != '/admin'){
      //código para autorização
      return true;
    } else {
      //acesso negado
      return false;
    }
  }
}

```
Agora coloque na propriedade 'guards' da sua Router.

```dart
  @override
  List<Router> get routers => [
        Router("/", module: HomeModule()),
        Router("/admin", module: AdminModule(), guards: [MyGuard()]),
      ];

```

Se colocar em uma rota módulo, o RouterGuard ficará global para aquela rota.

## Animação para Transição de Rota

Você pode escolher qual tipo de animação deseja setando o parametro **transition** do Router usando o enum **TransitionType**.

```dart
Router("/product", 
        module: AdminModule(),
        transition: TransitionType.fadeIn), //use para mudar a transição
```

Se usar o transition em um módulo, todas as rotas desse módulo herdarão essa animação de transição.

## Rotas na url com Flutter Web

O Sistema de rotas também reconhece o que é digitado na url do site (flutter web) então o que for digitado na url do browser será aberto no aplicativo. Esperamos que isso facilite o SEO para os sites feitos em Flutter Web, tornando-o mais único.

As rotas dinâmicas também se aplicam nesse caso.

```
https://flutter-website.com/#/product/1
```
Isso abrira a view Product e `args.params(['id'])` será igual a 1.


## Injeção de dependências

Você pode injetar qualquer classe no seu módulo usando o getter 'binds', como por exemplo classes **BLoC** ou **ChangeNotifier**

```dart
class AppModule extends MainModule {

  //aqui ficarão todas as classes que deseja Injetar no seu projeto (ex: bloc, dependency)
  @override
  List<Bind> get binds => [
    Bind((i) => AppBloc()), //usando bloc
    Bind((i) => Counter()), //usando ChangeNotifier
  ];

  //aqui ficarão as rotas do seu módulo
  @override
  List<Router> get routers => [
      Router("/", child: (_, args) => HomePage()),
      Router("/login", child: (_, args) => LoginPage()),
  ];

  //adicione seu widget principal aqui  
  @override
  Widget get bootstrap => AppWidget();
}
```

Vamos supor por exemplo que nós queremos recuperar o AppBloc dentro do HomePage.

```dart
//código do bloc
import 'package:flutter_modular/flutter_modular.dart' show Disposable;

//você pode herdar ou implementar a partir do Disposable para configurar um dispose para sua classe, se não não tiver um.
class AppBloc extends Disposable {

  StreamController controller = StreamController();

  @override
  void dispose() {
    controller.close();
  }
}
```

## Recuperando na view usando injeção.

Você tem algumas formas de recuperar as suas classes injetadas.

```dart

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    //você pode usar o objeto Inject para recuperar.
    final appBloc = Modular.get<AppBloc>();
    //...
  }
}
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

A mesma estrutura de um MainModule/ChildModule. Muito útil para usar em uma TabBar com páginas modulares

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

## Consumindo uma Classe ChangeNotifier


Exemplo de uma classe `ChangeNotifier`:

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

você pode usar o Consumer para gerenciar o estado de um bloco de widget.

```dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Home"),
      ),
      body: Center(
        //reconhece a classe ChangeNotifier e reconstroi quando é chamado o notifyListeners()
        child: Consumer<Counter>(
          builder: (context, value) {
            return Text('Counter ${value.counter}');
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          //recuperando a classe diretamente e executando o método de incrementação
          get<Counter>().increment();
        },
      ),
    );
  }
}

```

## Criando Módulos Filhos

Você pode criar outros módulos no seu projeto, para isso, em vez de herdar de `MainModule`, deve-se herdar de `ChildModule`.

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

A partir disto você pode chamar seus módulos na rota do módulo principal.

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

Pense em dividir seu código em módulos como por exemplo, `LoginModule`, e dentro dele colocar as rotas relacionadas a esse módulo. Ficará muito mais fácil a manutenção e o compartilhamento do código em outro projeto.

## Lazy Loading

Outro benefício que ganha ao trabalhar com módulos é carrega-los "preguiçosamente". Isso significa que sua injeção de dependência ficará disponível apenas quando você navegar para um módulo, e assim que sair dele, o Modular fará uma limpeza na memória removendo todas a injeções e executando os métodos de `dispose()` (se disponível) em cada classe injetada referênte aquele módulo).

## Testes Unitários

Você pode usar o sistema de injeção de dependências para substituir Binds por Binds de mocks, como por exemplo de um repositório. Você pode fazer também usando "Inversão de Controles"

```dart
@override
  List<Bind> get binds => [
        Bind<ILocalStorage>((i) => LocalStorageSharePreferences()),
      ];
```

Temos que importar o "flutter_modular_test" para usar os métodos que auxiliarão com a Injeção no ambiente de testes.

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


## Roadmap

Este é o nosso roteiro, sinta-se a vontade para requisitar alterações.

| Funcionalidades                        | Progresso |
| :------------------------------------- | :------: |
| DI por Módulo                          |    ✅    |
| Rotas por Módulo                       |    ✅    |
| Widget Consume para ChangeNotifier     |    ✅    |
| Auto-dispose                           |    ✅    |
| Integração com flutter_bloc            |    ✅    |
| Integração com mobx                    |    ✅    |
| Rotas multiplas                        |    ✅    |
| Passar argumentos por rota             |    ✅    |
| Parâmetros de url por rota             |    ✅    |
| Animação de Transição de Rota          |    ✅    |

## Funcionalidades e Bugs

Por favor envie seu pedido de funcionalidades no [rastreador de problemas](https://github.com/Flutterando/modular/issues).

Criado a partir de modelos disponibilizados pelo Stagehand sob um estilo BSD
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

