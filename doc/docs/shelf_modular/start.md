---
sidebar_position: 1
---

# Start

O **shelf_modular** usa o **modular_core** para desenhar APIs!
Isso significa usar a estrutura do Modular no backend também, mantendo o sistema de injeção de dependências
e rotas trabalhar com REST e Websocket.

## The Shelf

O **shelf** é um middleware feito para o Dart inspirado no **Connect** do Javascript tendo também alguma
semelhança com o **express.js**. 

O **shelf_modular** usa o **shelf** para lidar com as requisições e respostas, o que o torna compatível com qualquer outro package feito para o **shelf** como o **shelf_proxy** ou **shelf_static**.


## **shelf_modular** VS **flutter_modular**

Temos poucas diferenças entre os dois packages, a principal é que o **flutter_modular** só funcionana em um ambiente Flutter enquanto o **shelf_modular** depende do **shelf**, por isso os dois packages são nomeados
com sua dependência principal a frente: **flutter_**, **shelf_**.

Na prática, o **shelf_modular** é um clone do **flutter_modular**, retornando um objeto **Response** nas rotas
em vez de um Widget.

Foi adicionado um novo construtor no sistema de injeção de dependências chamado **Bind.scoped**, para manter a instância de um **Bind** durante a requisição e destruindo-o ao final da requisição. Veramos melhor o seu funcionanmento mais a frente.

## Start a project

Para começar, criaremos um novo projeto **Dart** usando o comando ``` dart create backend_app``` ou diretamente 
pela IDE que preferir.

:::danger ATTENTION

NÃO CRIE UM PROJETO FLUTTER!

:::

:::info TIP

Uma versão do Dart vem acoplada ao SDK do Flutter, por tanto, não é necessário baixar o Dart separadamente.

:::

:::info TIP

Talvez seu novo projeto Dart não tenha os códigos na pasta **lib/**.
Esse é um padrão de projetos do Dart, mas isso pode incomodar desenvolvedores Flutter, então podemos criar a pasta **lib/** e colocar seus códigos lá.

Mesmo assim é recomendado iniciar manter o arquivo de inicialização na pasta **bin/**. Sendo assim, podemos deixar apenas o arquivo que contém a **main()** na pasta **bin/**.

:::

Agora vamos adicionar o **shelf** e o **shelf_modular** diretamente no **pubspec.yaml ou usando o comando abaixo:

```
dart pub add shelf shelf_modular
```

ficando assim:

```yaml

dependencies:
  shelf: <last-version>
  shelf_modular: <last-version>

```

Agora estamos prontos para iniciar nossa API.

## Inicializando o projeto

Precisamos iniciar o Modular no nosso arquivo de inicialização, ou seja, o que contem a função **main()**.
Caso esteja seguindo o padrão proposto nas dicas acima, esse arquivo estará na pasta **lib/**.

```dart title="bin/backend_app.dart"

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_modular/shelf_modular.dart';

void main(List<String> arguments) async {
    final server = await io.serve(Modular(module: AppModule()), '0.0.0.0', 3000);
    print('Server started: ${server.address.address}:${server.port}');
}

```

O **AppModule()** é uma classe que herda de **Module**, e que pode ficar na pasta **lib/** para tornar o código
mais semelhante a um projeto Flutter padrão por exemplo.

```dart title="lib/app_module.dart"
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.get('/', () => Response.ok('OK!')),
      ];
}
```

Isso é tudo! Para iniciar o projeto use o comando:

```
dart run

// OR

dart bin/backend_app.dart
```

:::info TIP

Usuários do **VSCode** podem configurar o launch.json para ter acesso a mais opções de depuração como breakpoint.

:::