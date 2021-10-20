---
sidebar_position: 2
---

# Rotas

O **shelf_modular** está preparando para receber requisições respeitando os métodos **GET**, **POST**, **PUT**, **DELETE**, **PATCH**, aplicando o REST.
Podemos utilizar os construtores da classe **Route** para informar o método, o caminho e o handler.
Rotas são adicionadas nos módulos. Tomaremos como exemplo o AppModule e adicionaremos algumas rotas

```dart title="lib/app_module.dart"
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.get('/products', () => Response.ok('All products')),
        Route.get('/users', () => Response.ok('All users')),
      ];
}
```

Agora você pode testar no seu navegador ou usando algum programa (wget/curl):

```
http://localhost:3000/users
http://localhost:3000/products
```

## Magic Handler

Toda rota tem uma função que retorna um **Response**. Essa função pode ter até 3 parâmetros opcionais: **Request**, **Injector** e **ModularArgments**.

```dart
Route.get('/', (Request request) => Request.ok('ok'));
Route.get('/2', (Request request, Injector injector) => Request.ok('ok'));
Route.get('/3', (Request request, Injector injector, ModularArguments args) => Request.ok('ok'));
//or
Route.get('/4', (Injector injector) => Request.ok('ok'));
Route.get('/5', (ModularArguments args) => Request.ok('ok'));
Route.get('/6', (Injector injector, ModularArguments args) => Request.ok('ok'));
...
```
Os parâmetros do Magic Handler são injetados pelo **shelf_modular** e podem ser usados em qualquer ordem, tornando a função handler mais dinâmica mesmo sem usar Reflection (dart:mirrors). Então o que são esses parametros?

- **Request**: Contém as informação da requisição vinda do cliente.
- **Injector**: Semelhante ao **Modular.get**. O Service Locator é disponibilizado dessa forma para facilitar os testes.
- **ModularArguments**: Amarzena os parametros e queries da requisição, bem como o payload(em json) do corpo de uma requisição POST por exemplo.

:::info TIP

Fique a vontade para embaralhar ou omitir alguns parametros.

:::

:::danger ATTENTION

É obrigatório adicionar o tipo do parâmetro. 

:::


## Argumento de rotas.

O **shelf_modular** tem suporte a rota dinâmicas e também entende query e corpo da requisição. O objeto que representa isso é o **ModularArguments**. Vejamos um exemplo com uma camada REST completa:


```dart title="lib/app_module.dart"
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.get('/users', () => Response.ok('All users')),
        Route.get('/users/:id', (ModularArguments args) => Response.ok('user id ${args.params['id']}')),
        //passed json body in request
        Route.post('/users', (ModularArguments args) => Response.ok('New user added: ${args.data}')),
        Route.put('/users/:id', (ModularArguments args) => Response.ok('Updated user id ${args.params['id']}')),
        Route.delete('/users/:id', (ModularArguments args) => Response.ok('Deleted user id ${args.params['id']}')),
      ];
}
```

:::info TIP

Você pode usar query ao invés de params acessando ```http://localhost:3000/users?id=1``` e recuperando com o **ModularArguments.query** usando ```final id = ModularAguments.query['id'];```

:::

:::info TIP

Note que no **Route.post** foi usado o **ModularArguments.data** em vez de **ModularArguments.params**.
Isso porque o **ModularArguments.data** pega o corpo da requisição (como por exemplo um json).

Para pegar um Multipart, deve usar o **Request.read()**.
:::

## Resources

As vezes precisamos agregar rotas em uma camada para facilitar a compreenção dos dados, por isso usamos objetos do tipo **Resource**. Bastar criar uma classe que herde de **Resource** e implementar a Lista de ModularRoute. Veja o exemplo de um CRUD completo:

```dart title="lib/user_resource.dart
class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/', () => getAllUsers),
        Route.get('/:id', getUser),
        //passed json body in request
        Route.post('/', addUser),
        Route.put('/:id', updateUser),
        Route.delete('/:id', deleteUser),
      ];

  FutureOr<Response> getAllUsers() => Response.ok('All users');
  FutureOr<Response> getUser(ModularArguments args) => Response.ok('user id ${args.params['id']}');
  FutureOr<Response> addUser(ModularArguments args) => Response.ok('New user added: ${args.data}');
  FutureOr<Response> updateUser(ModularArguments args) => Response.ok('Updated user id ${args.params['id']}');
  FutureOr<Response> deleteUser(ModularArguments args) => Response.ok('Deleted user id ${args.params['id']}');
}
```

Agora, basta adicionar o **UserResource** ao **AppModule** usando o construtor **Route.resource**:

```dart title="lib/app_module.dart"
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'user_resource.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
      Route.resource('/users', resource: UserResource()),
    ];
}
```

Para ver se está tudo funcionando, basta testar em um navegador:
```
http://localhost:3000/users/
```

:::info TIP

Prestando atenção no seguimento da URL, percebemos que o nome da rota **/users** é concatenado com o as rotas do resource, ficando: **/users** + **/**.

:::

