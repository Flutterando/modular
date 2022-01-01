---
sidebar_position: 4
---

# Module

A module clusters all rotes and binds relative to an scope or feature of the application and may contain sub modules forming one single composition. 
It means that to access a bind, it needs to be in a parent module that's already started, otherwise, the bind will not be visible to be recovered using a system injection. 
A Module’s lifetime ends when the last page is closed.

## Routing between modules

The **shelf_modular** works with "dynamic routes”, segments, query, fragments, very similar to what we see on web. Let’s take a look at the anatomy of a “path”. To access a route within a submodule, we will need to consider the segments of the route path represented by URI (Uniform Resource Identifier). For example:
```
/home/user/1
```

:::tip TIP

We call “segment” the text separated by `/`. For example, the URI `/home/user/1` has three segment, being them [‘home’, ‘user’, ‘1’];

:::

Use the **Route.module** builder to add a module to another:

```dart {5}
class AModule extends Module {
  @override
  List<ModularRoute> get routes => [
    Route.get('/', () => Response.ok('path -> /')),
    Route.module('/b-module', module: BModule()),
  ];
}

class BModule extends Module {
  @override
  List<ModularRoute> get routes => [
    Route.get('/', () => Response.ok('path -> /b-module/')),
    Route.get('/other', () => Response.ok('path -> /b-module/other')),
  ];
}
```
In this scenario, there are two routes in **AModule**, a **Route.get** called `/` and a **Route.module** called `/b-module`.

The **BModule** contains another two **Route.get** called `/` and `/other`, respectively. 

What would you call **Route.get** `/other`? 
The answer is in follow up. Assuming that **AModule** is the application’s root module, 
then the initial segment will be the name of the **BModule**, because we need to get a route that is within it.

```
/b-module
```
The next segment will be the name of the route we want, the `/other`.

```
/b-module/other
```
READY! When you execute the `http://localhost:3000/b-module/other’)` e verá a resposta: `path -> /b-module/other`.

The logic is the same when the submodule contains a route named as `/`. Understanding this, we assume that the available routes in this example are:
```
/                 =>  `path -> /` 
/b-module/        =>  'path -> /b-module/' 
/b-module/other   =>  'path -> /b-module/other'
```

:::tip TIP

When the concatenation of named routes takes place and generates a `//`, this route is normalized to `/`. This explains the first example of the session.

:::

:::tip TIP

If there is a route called `/` in the submodule **shelf_modular** will understand it as “default” route, if no other segment is already placed after the module. For example:

`/b-module`  =>  'path -> /b-module/'

Same as:

`/b-module/` =>  'path -> /b-module/' 

:::

## Module import

A module can be created only to store binds. A use case would be established when we have a Shared or Core Module containing all the main binds and distributed among all modules. To use a module only with binds, we must import it into a module containing routes. See the next example:

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
  ...
}
```
Note that **CoreModule** binds are marked with the export flag `export: true`, this means that the bind can be imported into another module.

:::danger ATTENTION

The module import is only for **Binds**. **Routes** won't be imported.

:::
