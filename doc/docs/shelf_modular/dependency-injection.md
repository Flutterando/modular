---
sidebar_position: 3
---

# Dependency Injection

Falamos um pouco sobre o padrão de injeção de dependencyas na sessão do **flutter_modular**, a qual pode ser acessada [clicando aqui](https://modular.flutterando.com.br). Recomendamos fortemente a leitura principalmente para quem não conhece ou quer conhecer melhor esse padão de projetos.

## Instance registration

The strategy for building an instance with its dependencies comprise register all objects in a module and
manufactures them on demand or in single-instance form(singleton). This 'registration' is called **Bind**.

There are a few ways to build a Bind to register object instances:


- *Bind.scoped*: Controi uma instancia que sobrevive durante toda a requisição, sendo destruida ao final da requisição.
- *Bind.singleton*: Build an instance only once when the module starts.
- *Bind.lazySingleton*: Build an instance only once when prompted.
- *Bind.factory*: Build an instance on demand.
- *Bind.instance*: Adds an existing instance.

We register the binds in **AppModule**:

```dart
class AppModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.factory((i) => XPTOEmail())
    Bind.factory<EmailService>((i) => XPTOEmailService(i()))
    Bind.scoped((i) => Client(i()))
  ];
  
  ...
}
```
Note that we placed an `i()` instead of the dependencies instance. This will be responsible to allocate the
dependencies automatically.

To get a resolved instance use `Modular.get`:

```dart
final client = Modular.get<Client>();

// or set a default value
final client = Modular.get<Client>(defaultValue: Client());
```

:::tip TIP

A default constructor **Bind()** is the same as **Bind.lazySingleton()**;

:::

## AsyncBind

**flutter_modular** can also resolve asynchronous dependencies. To do this, use **AsyncBind** instead of **Bind**:

```dart
class AppModule extends Module {
  @override
  List<Bind> get binds => [
    AsyncBind<SharedPreferences>((i) => SharedPreferences.getInstance()),
    ...
  ];
  ...
}
```

By now we need to transform the AsyncBind into synchronous Bind in order to resolve the other instances. Therefore, 
we use **Modular.isModuleReady()** passing the module type in generics;

```dart
await Modular.isModuleReady<AppModule>();
```
This action will convert all AsyncBinds to synchronous Binds and singletons.

:::tip TIP

We can get the asynchronous instance directly too without having to convert to a synchronous bind using
**Modular.getAsync()**;

:::

## Auto Dispose

For registered objects that are not part of this list, we can implement a **Disposable** interface on the instance where we want to run an algorithm before dispose:

```dart
class MyController implements Disposable {
  final controller = StreamController();

  @override
  void dispose() {
    controller.close();
  }
}
```

**shelf_modular** also offers a singleton removal option from the dependency injection system 
by calling the **Modular.dispose**() method even with an active module:

```dart
Modular.dispose<MySingletonBind>();
```

