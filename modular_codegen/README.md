![CI](https://github.com/Flutterando/modular/workflows/CI/badge.svg)

# modular_codegen

Code generation for `flutter_modular`. Injection automation. Annotations `Injectable`, `Param` and `Data`.

## Installation

Open your project's `pubspec.yaml` and add `modular_codegen` and `build_runner` as a dev dependency:

```yaml
dev_dependencies:
  modular_codegen: any
  build_runner: any
```

If you want to use null-safety with flutter2, use a null-safety version.

```
dev_dependencies:
  modular_codegen: 3.0.0-nullsafety.2
  build_runner: any
```

## Injection automation

Annotate your class with `Injectable`. Don't forget the `part` directive.

```dart
import 'package:flutter_modular/flutter_modular.dart'; // ← for using Injectable annotation

part 'home_controller.g.dart'; // ← part directive with your_file_name.g.dart

@Injectable() // ← Injectable annotation
class HomeController {
    ...
```

Execute the `build_runner` in the root of your project:
```
flutter pub run build_runner build
```

The generator will provide a `$ClassName` in the generated file, that can be injected in your module `binds`:

```dart
class HomeModule extends Module {
  @override
  List<Bind> get binds => [
        $HomeController, // ← As the class name was `HomeController`, the generated injectable is `$HomeController`
      ];
```

Injection automation will rely on the class constructor's parameters to generate the bindings.


```dart
// home_controller.dart
part 'home_controller.g.dart'; // ← part directive with your_file_name.g.dart

@Injectable() // ← Injectable annotation
class HomeController {
    final ApiRepository repository;
    HomeController({
        this.repository, // ← The parameters of the constructor will define the generated binding
    })

    ...
}

// Generated home_controller.g.dart
Bind(i) => HomeController(
    repository: i.get<ApiRepository>(), // ← repository parameter from constructor
);
```

### Injectable configuration

`Injectable` annotation has two optional boolean params: `singleton` and `lazy`. By default, they are set to `true`. Thus, you can easily disable singleton behavior and lazy-loading behavior by passing these arguments. 

Example:

```dart
@Injectable(singleton: false) // ← Disables singleton behavior
class ProductController {
    ...
```

## Route parameters and arguments (Navigator)

If you need to pass data to your controller through the Navigator, you may annotate your constructor's parameters with `Param` or `Data`.

### `Param` for dynamic route

For example, if your route URL is going to have an `id` parameter, provide a `String` parameter with the same name and annotated with `Param`.

```dart
part 'product_controller.g.dart'; // ← part directive with your_file_name.g.dart

@Injectable() // ← Injectable annotation
class ProductController {
    final String id

    ProductController({@Param this.id}) // ← This annotation will allow you to pass the `id` parameter in the route URL, like `/product/:id`

    ...
}
```

### `Data` for Navigator arguments

Similarly, if you are going to pass complex objects to your route, annotate your constructor's parameters with `Data`.

```dart
part 'product_controller.g.dart'; // // ← part directive with your_file_name.g.dart

@Injectable() // ← Injectable annotation
class ProductController {
    final ProductItem item

    ProductController({@Data this.item}) //<- add @Data annotation
    ...
}
```

Then, pass the `argument` parameter to `Modular.to.pushNamed`:

```dart
Modular.to.pushNamed('/product', arguments: ProductItem());
```

## Features and bugs

Please send feature requests and bugs at the [issue tracker](https://github.com/Flutterando/modular/issues).
