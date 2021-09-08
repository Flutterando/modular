---
sidebar_position: 1
---

# Inicio

O **flutter_modular** foi construído usando o motor do **modular_core** que é responsável pelo sistema de injeção de dependências e gerência de rotas. A implementação do sistema de Rotas simula uma árvore de módulos, tal qual como o Flutter faz em suas árvores de widgets, elementos e redenrização. Por isso, podemos adicionar um módulo dentro de outro criando vínculos de paternidade.


## Inspirações do Angular

Todo sistema do **flutter_modular** veio de estudos realizado no Angular (outro framework da Google) e adaptado para o mundo do Flutter. Por isso, existe muitas semelhanças entre o **flutter_modular** e o Sistema de Rotas e Injeção de Dependências do Angular.

As rotas são refletidas no Aplicativo usando as features do novo Navigator 2.0, permitindo assim o uso de multiplos navegadores aninhados. Chamamos essa feature de RouterOutlet, assim como no Angular.

Assim como no Angular, cada módulo pode ser completamente independente, fazendo com que o mesmo módulo possa ser usado em vários produtos. Dividindo os módulos em packages, poderemos chegar perto de uma estrutura de micro-frontends.

## Começando um Projeto

Nosso objetivo inicial será criar um app inicial, ainda sem estrutura ou arquitetura definida, para que possamos
estudar os componentes iniciar do **flutter_modular**.

Crie um novo projeto Flutter:
```
flutter create my_smart_app
```

Agora adicionar o **flutter_modular** no pubspec.yaml do projeto:
```yaml

dependencies:
  flutter_modular: any

```

Se tudo der certo, então estamos pronto para seguir em frente!

:::tip DICA

A CLI do Flutter tem uma ferramenta que facilita a inclusão dos packages no projeto. Use o comando:

`flutter pub add flutter_modular`

:::

## O ModularApp

Precisamos adicionar o Widget ModularApp na raiz do nosso projeto. Vamos alterar nosso arquivo **main.dart**:

```dart title="lib/main.dart"

import 'package:flutter/material.dart';

void main(){
  return runApp(ModularApp(module: <MainModule>, child: <MainWidget>));
}

```

O **ModularApp** nos obriga a adicionar um módulo principal e um widget principal. O que iremos fazer a seguir.
Esse Widget faz a configuração inicial para que tudo funcione bem. Para mais detalhes acesse a doc do **ModularApp**.

:::tip DICA

É importante que o **ModularApp** seja o primeiro widget do seu app!

:::

## Criando o Módulo Principal

Um módulo representa a aglomeração de Rotas e Binds. 
- **ROUTE**: Configuração de Página elegível para navegação.
- **BIND**: Representa um objeto que ficará disponível para injeção a outras dependências.

Falaremos mais detalhes sobre a frente.

Podemos ter vários módulos, mas por hora, vamos criar um módulo principal chamado de **AppModule**:

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

Observer que o módulo é apenas uma classe que herda da classe **Module**, sobreescrevendo as propriedades **binds** e **routes**.
Com isso temos um mecanismo de rotas e injeções0 separado da aplicação podendo ser aplicado tanto em um contexto global(como estamos fazendo) como em um contexto local, como por exemplo, criar um módulo contendo apenas os binds e rotas
de uma feature específica!

Adicionamos o **AppModule** no ModularApp. Agora precisamos de uma rota inicial, então vamos criar um StatelessWidget
para servir como página inicial.

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
Criamos um Widget chamado de **HomePage** e adicionamos a sua instancia em uma rota chamada de **ChildRoute**.
:::tip DICA

Existe dois tipos de ModularRoute, o **ChildRoute** e **ModuleRoute**. 

O **ChildRoute** server para construir um Widget enquanto o **ModuleRoute** concatena outro módulo.

:::

## Criando o Widget Principal

A função do Widget principal é instanciar o MaterialApp ou CupertinoApp.
Nesses Widgets principais também é necessário configurar o sistema customizado de rotas. Para isso, o **flutter_modular** possui uma extension que automatiza esse processo. Para esse próximo código iremos usar
o **MaterialApp**, porém o processo é exatamente o mesmo para o CupertinoApp.


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

Aqui criamos um Widget chamado de **AppWidget** contendo uma instancia do **MaterialApp**. Note que no final chamamos
o método **.modular()** que foi adicionado ao **MaterialApp** por extension.

Isso é o suficiente para rodar um app Modular. Nós próximos passos exploremos a navegação.