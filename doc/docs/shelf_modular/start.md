---
sidebar_position: 1
---

# Start

The **shelf_modular** uses **modular_core** to draw APIs!
This means using the Modular framework in the backend as well, keeping the dependency injection system
and routes work with REST and Websocket.

## The Shelf

The **shelf** is a middleware made for Dart inspired by the **Connect** of Javascript and also has some
similarity to **express.js**. 

The **shelf_modular** uses **shelf** to handle requests and responses, which makes it compatible with any other package made for **shelf** like **shelf_proxy** or **shelf_static* *.


## **shelf_modular** VS **flutter_modular**

We have few differences between the two packages, the main one is that **flutter_modular** only works in a Flutter environment while **shelf_modular** depends on **shelf**, so the two packages are named
with its main dependency in front: **flutter_**, **shelf_**.

In practice, **shelf_modular** is a clone of **flutter_modular**, returning a **Response** object in routes
instead of a Widget.

A new constructor has been added to the dependency injection system called **Bind.scoped**, to keep the instance of a **Bind** during the request and destroy it at the end of the request. We will see how it works better later on.

## Start a project

To get started, we'll create a new **Dart** project using the ``` dart create backend_app``` command or directly
by the IDE you prefer.

:::danger ATTENTION

DO NOT CREATE A FLUTTER PROJECT!

:::

:::info TIP

A version of Dart comes bundled with the Flutter SDK, so there is no need to download Dart separately.

:::

:::info TIP

Maybe your new Dart project doesn't have the codes in the **lib/** folder.
This is default for Dart projects, but this might annoy Flutter developers, so we can create the **lib/** folder and put your code there.

It is still recommended to start keeping the initialization file in the **bin/** folder. So, we can just leave the file containing **main()** in the **bin/** folder.

:::

Now let's add **shelf** and **shelf_modular** directly into **pubspec.yaml** or using the command below:

```
dart pub add shelf shelf_modular
```

getting a result like this:

```yaml

dependencies:
  shelf: <last-version>
  shelf_modular: <last-version>

```

We are now ready to start our API.

## Starting the project

We need to start Modular in our initialization file, that is, the one that contains the **main()** function.
If you are following the pattern proposed in the tips above, this file will be in the **bin/** folder.

```dart title="bin/backend_app.dart"

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_modular/shelf_modular.dart';

void main(List<String> arguments) async {

    final modularHandler = Modular(
      module: AppModule(), // Initial Module
      middlewares: [
        logRequests(), // Middleware Pipeline
      ],
    );

    final server = await io.serve(modularHandler, '0.0.0.0', 3000);
    print('Server started: ${server.address.address}:${server.port}');
}

```

**AppModule()** is a class that inherits from **Module**, and which can be in the **lib/** folder to make code
more similar to a standard Flutter project for example.

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

That is all! To start the project use the command:

```
dart run

// OR

dart bin/backend_app.dart
```

:::info TIP

The **VSCode** users can configure **launch.json** to have access to more debugging options like breakpoint.

```json title=".vscode/launch.json"
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "backend",
            "request": "launch",
            "type": "dart",
            "program": "bin/backend_app.dart"
        }
    ]
}
```


:::
