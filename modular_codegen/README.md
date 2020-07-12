![CI](https://github.com/Flutterando/modular/workflows/CI/badge.svg)

# modular_codegen

Code Generate for flutter_modular. Inject Automation. Annotation @Injectable, @Param and @Data.

## Instalation

Open your project's `pubspec.yaml` and add `modular_codegen` and `build_runner` as a dev dependency:

```yaml
dev_dependencies:
  modular_codegen: any
  build_runner: any
```

## Injection automation

Add annotation @Injectable() above your class. Not forget the part generated.

```dart
part 'home_controller.g.dart'; //<- added part "file-name.g.dart"

@Injectable() //<- added annotation here
class HomeController {
    ...
```

Now, exec the builder_runner
```
flutter pub run build_runner build
```

Add your injectable class in respective module binds.
Use: "$" + "ClassName" -> $ClassName just;

```dart
class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
        $HomeController, //<- $ + HomeController
      ];
```

Injection automation will rely on the class construct's data to create the binds.


```dart
part 'home_controller.g.dart'; //<- added part "file-name.g.dart"

@Injectable() //<- added annotation here
class HomeController {
    final ApiRepository repository;
    HomeController({this.repository})

    ...
}
```

Generated code is like:
```dart
Bind(i) => HomeController(repository: i.get<ApiRepository>());
```

## Route Params and Arguments (Navigator)

If you need to receive a dynamic parameter in the url or an object added as an argument in the Navigator, just use the @Param or @Data annotations in the construct.

### dynamic route example: `product/:id`

Just added @Param annotation with same name (and String type).

```dart
part 'product_controller.g.dart'; //<- added part "file-name.g.dart"

@Injectable() //<- added annotation here
class ProductController {
    final String id

    ProductController({@Param this.id}) //<- add @Param annotation

    ...
}
```



### Navigator arguments example:

```dart
Modular.to.pushNamed('/product', arguments: ProductItem());
```

Use @Data annotation with same type for object argument;

```dart
part 'product_controller.g.dart'; //<- added part "file-name.g.dart"

@Injectable() //<- added annotation here
class ProductController {
    final ProductItem item

    ProductController({@Data this.item}) //<- add @Data annotation
    ...
}
```

## Injection config

`@Injectable` annotation has two boolean params: `singleton` and `lazy`.
You can disable the singleton or lazy loading behavior of the injection:

```dart
@Injectable(singleton: false) 
class ProductController {
    ...
```

## Features and bugs

Please send feature requests and bugs at the [issue tracker](https://github.com/Flutterando/modular/issues).