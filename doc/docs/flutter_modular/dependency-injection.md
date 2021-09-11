---
sidebar_position: 3
---

# Dependency Injection

We generally code with maintenance and scalability in mind, applying project-specific patterns
to a given function and improving the structure of our code. We must to pay attention on our code, 
or else it can be a covertly problem. Let's look at the practical example:

```dart
class Client {
  void sendEmail(String email, String title, String body){
    final xpto = XPTOEmail();
    xpto.sendEmail(email, title, body);
  }
}
```

Here we have a **Client** class with a method called **sendEmail()** running the send routine on **XPTOEmail** class instance.
Despite being a simple and functional approach, having a class instance within the method, it presents some problems:

- Makes it impossible to replace the instance `xpto`.
- Makes the Unit Tests difficult, as you would not be able to create `XPTOEmail()` Fake/Mock instance.
- Entirely dependent on the functioning of an external class.

We call it "Dependency Coupling" when we use an outer class in this way, because the *Client* class
is totally dependent on the functioning of the **XPTOEmail** object.

To break a class's bond with its dependency, we generally prefer to "inject" the dependency instances by constructor, setters or methods. That's what we call "Dependency Injection".

Let's fix the **Customer** class by injecting the **XPTOEmail** instance by constructor:

```dart
class Client {

  final XPTOEmail xpto;
  Client(this.xpto);

  void sendEmail(String email, String title, String body){
    xpto.sendEmail(email, title, body);
  }
}
```
Thereway, we reduce the coupling **XPTOEmail** object did to the **Client** object.

We still have a problem with this implementation. Despite *cohesion*, the Client class has a dependency on an external source,
and even being injected by constructor, replacing it with another email service would not be a simple task.
Our code still have coupling, but we can improve this using `interfaces`. Let's create an interface
to sign the **sendEmail** method. With this any class that implements this interface can be injected into the class **Client**:

```dart
abstract class EmailService {
  void sendEmail(String email, String title, String body);
}

class XPTOEmailService implements EmailService {

  final XPTOEmail;
  XPTOEmailService(this.xpto);

  void sendEmail(String email, String title, String body) {
    xpto.sendEmail(email, title, body);
  }
}
```

So we can create implementations of any email services. Finally, let's replace the dependency on
XPTOEmail by the EmailService interface:

```dart
class Client {

  final EmailService service;
  Client(this.service);

  void sendEmail(String email, String title, String body){
    service.sendEmail(email, title, body);
  }
}
```

Then We create the **Client** instance:

```dart
//dependencies
final xpto = XPTOEmail();
final service = XPTOEmailService(xpto)

// instance
final client = Client(service);
```

This type of object creation solves the coupling but can increase the instance creation complexity, as we can see in the **Client** class. The **flutter_modular** Dependency Injection System solves this problem simply and effectively.

## Instance registration

The strategy for building an instance with its dependencies comprise register all objects in a module and
manufactures them on demand or in single-instance form(singleton). This 'registration' is called **Bind**.

There are a few ways to build a Bind to register object instances:


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
    Bind.singleton((i) => Client(i()))
  ];
  
  ...
}
```
Note that we placed an `i()` instead of the dependencies instance. This will be responsible for resolving the
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

By now we need to transform the AsyncBind into synchronous Bind in order to resolve the other instances. Thereunto 
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

The lifetime of a Bind singleton ends when its module 'dies'. But there are some objects that, by default, 
runs by an instance destruction routine and automatically removed from memory. Here they are:

- Stream/Sink (Dart Native).
- ChangeNotifier/ValueNotifier (Flutter Native).
- Store (Triple Pattern).

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

:::tip TIP

As BLoC is based on Streams, the memory release takes effect automatically.

:::

**flutter_modular** also offers a singleton removal option from the dependency injection system 
calling the **Modular.dispose**() method even with a active module:

```dart
Modular.dispose<MySingletonBind>();
```
