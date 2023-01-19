---
sidebar_position: 2
---

# Routes

The **shelf_modular** is prepared to receive requests respecting the methods **GET**, **POST**, **PUT**, **DELETE**, **PATCH**, applying the REST.
We can use the **Route** class constructors to inform the method, the path and the handler.
Routes are added in modules. We'll take the AppModule as an example and add some routes:

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

Now you can test it in your browser or using some program (wget/curl):

```
http://localhost:3000/users
http://localhost:3000/products
```

You can user POSIX in route name:

```dart title="lib/app_module.dart"
...
  List<ModularRoute> get routes => [
        Route.get('/any/**', () => Response.ok('All products')),
        Route.get('/**', () => Response.notFound(body: 'not found')),
      ];

```

```
http://localhost:3000/any/test1   - ok
http://localhost:3000/any/test2   - ok
http://localhost:3000/any/test3   - ok


http://localhost:3000/other  -  [404] -> 'not found'
```

## Magic Handler

Every route has a function that returns a **Response**. This function can have up to 3 optional parameters: **Request**, **Injector** and **ModularArgments**.

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
Magic Handler parameters are injected by **shelf_modular** and can be used in any order, making the handler function more dynamic even without using Reflection (dart:mirrors). So what are these parameters?

- **Request**: Contains the information of the request coming from the client.
- **Injector**: Similar to **Modular.get**. Service Locator is made available in this way to facilitate testing.
- **ModularArguments**: It stores the parameters and queries of the request, as well as the payload (in json) of the body of a POST request, for example.

:::info TIP

Feel free to shuffle or omit some parameters.

:::

:::danger ATTENTION

It is mandatory to specify the parameter's type. (ex: **Request** req);

:::


## Route Arguments.

**shelf_modular** supports dynamic routing and also understands query and request body. The object that represents this is **ModularArguments**. Let's look at an example with a complete REST layer:

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

You can use query instead of params by going to ```http://localhost:3000/users?id=1``` and retrieving with **ModularArguments.query** using ```final id = ModularAguments.query[ 'id'];```.

:::

:::info TIP

Note that in **Route.post** **ModularArguments.data** was used instead of **ModularArguments.params**.
That's because **ModularArguments.data** takes the body of the request (such as a json).

To get a Multipart, you must use **Request.read()**.

:::

## Resources

Sometimes we need to aggregate routes in a layer to make the data easier to understand, that's why we use **Resource** type objects. Just create a class that inherits from **Resource** and implement the ModularRoute List. See an example of a complete CRUD:

```dart title="lib/user_resource.dart
class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/user', () => getAllUsers),
        Route.get('/user/:id', getUser),
        //passed json body in request
        Route.post('/user', addUser),
        Route.put('/user/:id', updateUser),
        Route.delete('/user/:id', deleteUser),
      ];

  FutureOr<Response> getAllUsers() => Response.ok('All users');
  FutureOr<Response> getUser(ModularArguments args) => Response.ok('user id ${args.params['id']}');
  FutureOr<Response> addUser(ModularArguments args) => Response.ok('New user added: ${args.data}');
  FutureOr<Response> updateUser(ModularArguments args) => Response.ok('Updated user id ${args.params['id']}');
  FutureOr<Response> deleteUser(ModularArguments args) => Response.ok('Deleted user id ${args.params['id']}');
}
```

Now, just add **UserResource** to **AppModule** using the **Route.resource** constructor:

```dart title="lib/app_module.dart"
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'user_resource.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
      Route.resource(UserResource()),
    ];
}
```

To see if everything is working, just test it in a browser:

```
http://localhost:3000/users
```

:::info TIP

Paying attention to the following URL, we notice that the route name **/users** is concatenated with the resource routes, being: **/users** + **/**.

:::

