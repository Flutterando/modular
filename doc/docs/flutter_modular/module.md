---
sidebar_position: 4
---

# Module

Um módulo aglomera todas as rotas e binds referente a um escopo/feature da aplicação e pode
conter sub-módulos formando uma composição. Isso significa que para ter acesso a um Bind, ele
precisa está em um módulo pai já iniciado, caso o contrário, o Bind não será visível para ser
recuperado usando o sistema de injeção. O ciclo de vida de um módulo finaliza quando a ultima página do módulo for fechada.



## O ModuleRoute

É do tipo **ModularRoute** e contém algumas propriedades existentes no **ChildRoute** como,
*transition*, *customTransition*, *duration* e *guards*.

:::tip DICA

É importante lembrar que ao adicionar uma propriedade no **ModuleRoute**, TODAS suas rotas
filhas herdaram esse comportamento.

Por exemplo, se adicionar na propriedade *transition* o valor *TransitionType.fadeIn*, as
rotas filhas também terão sua propriedade *transition* alterada para o mesmo tipo de transição.

Porém, se definir uma propriedade na rota filha de um **ModuleRoute**, a rota filha ignorará
a alteração do seu módulo e manterá o valor definida no filho.

:::

No *Modular*, tudo é feito observando as rotas, então vamos criar um segundo módulo para incluir
usando o **ModuleRoute**:

```dart title="lib/main.dart" {23,27-35}
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
    ModuleRoute('/', module: HomeModule()),
  ];
}

class HomeModule extends Module {
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

O que vemos aqui:

- Criamos o módulo **HomeModule** e adicionamos o widget **HomePage** com o **ChildRoute**.
- Depois adicionamos o **HomeModule** ao **AppModule** usando o **ModuleRoute**.
- Por fim, juntamos as rotas do **HomeModule** no **AppModule**.

Entraremos agora em um assunto fundamental para entender o roteamento quando um módulo 
é filiado a outro.

:::danger ATENÇÃO

Não é permitido usar rotas dinâmicas como nome de um **ModuleRoute**, pois compremeteria
a semântica e o objetivo desse tipo de rota.
A ponta final de uma rota deve ser sempre referênciada com o **ChildRoute**.

:::

## Roteamento entre módulos

O **flutter_modular** trabalha com "rotas nomeadas", com segmentos, query, fragments, muito
semelhante ao que vemos na Web. Vamos observar a anatomia de uma "path"
Para acessar uma rota dentro de um sub-módulo, precisaremos levar em consideração os segmentos
do caminho de rota representado por URI(Uniform Resource Identifier) Ex:
```
/home/user/1
```

:::tip DICA

Chamamos de "segmento" o texto separado por `/`.
Por exemplo, a URI `/home/user/1` tem 3 segmentos, sendo eles: ['home', 'user', '1'];

:::

A composição de uma rota deve conter o nome da rota (Declarada no **ModuleRoute**) e em seguida a rota filha. Veja o seguinte caso de uso:

```dart
class AModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => APage()),
    ModuleRoute('/b-module', module: BModule()),
  ];
}

class BModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => BPage()),
    ChildRoute('/other', child: (context, args) => OtherPage()),
  ];
}
```

Nesse cenário, existe duas rotas no **AModule**, um **ChildRoute** nomeado de `/` e um
**ModuleRoute** nomeado de `/b-module`.

O **BModule** contém outras duas **ChildRoute** nomeadas de `/` e `/other` respectivamente.

Como faria para chamar a **ChildRoute** `/other`? A resposta está no seguimento.
Partindo do princípio que **AModule** é o módulo raiz do aplicativo, então o segmento inicial será o nome do **BModule**, pois precisamos pegar uma rota que está dentro do mesmo:
```
/b-module
```
O próximo segmento será o nome da rota que queremos, a `/other`.

```
/b-module/other
```
PRONTO! Ao executar o **Modular.to.navigate('/b-module/other')** a página que irá aparecer
será o widget **OtherPage()**.

A lógica é a mesma quando o submódulo contém uma rota nomeada como `/`.
Entendendo isso, constatamos que as rotas disponíveis nesse exemplo são:
```
/                  =>  APage() 
/b-module/         =>  BPage() 
/b-module/other    =>  OtherPage() 
```

:::tip DICA

Quando a concatenação de rotas nomeadas acontece e gerá um `//`, essa rota é normalizada
para `/`.
Isso explica o primeiro exemplo da sessão.

:::

:::tip DICA

Se existir uma rota chamada `/` no sub-módulo, o **flutter_modular** entenderá como rota
"default" caso não sejá colocado outro segmento após ao do módulo.
Exemplo:

`/b-module`  =>  BPage()

O mesmo que:

`/b-module/` =>  BPage() 

:::

## Caminho Relativo vs Absoluto

Quando um caminho de rota é descrito de forma literal, então dizemos que se trata de um
caminho Absoluto, como por exemplo `/foo/bar`. Mas podemos nos basear no caminho atual vigente e usar a noção de POSIX para entrar
em uma rota. Por exemplo:

Estamos na rota `/foo/bar` e queremos ir para a rota `/foo/baz`. Usando o POSIX, basta
informar **Modular.navigate('./bar')**.

Note que existe um `./` no começo do caminho. Isso faz com que apenas o segmento final
seja trocado.

:::tip DICA

O conceito de caminho relativo é aplicado nos terminais, CMD e import de arquivos.

Expressões como `../` faria a substituição do penultimo segmento em diante.

:::

:::tip DICA

Utilize o conceito de rotas relativas para otimizar as navegações entre páginas do mesmo módulo.
Isso favorece o desacoplamento completo do módulo, pois não necessitará dos segmentos anteriores.

:::


## Importação de Módulo

Um módulo pode ser criado para armazenar apenas os binds. Um caso de uso nesse sentido seria quando
temos um Modulo Shared ou Core contendo todos os Binds principais e distribuidos entre todos os módulos.
Para usar um módulo unicamente com Binds, devemos importa-lo em um módulo contendo rotas. Vejamos um exemplo:

```dart {10-13}
class CoreModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.singleton((i) => HttpClient(), export: true),
    Bind.singleton((i) => LocalStorage(), export: true),
  ]
}

class AppModule extends Module {
  @override
  List<Module> get imports => [
    CoreModule(),
  ]

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => HomePage()),
  ];
}
```
Note que os binds do **CoreModule** estão marcados com a flag `export: true`, isso significa que o **Bind** pode
ser importado em outro módulo.

:::danger ATENÇÃO

A importação de módulos serve apenas para **Binds**.
Rotas não serão importadas nessa modalidade.

:::
