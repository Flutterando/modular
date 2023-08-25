---
sidebar_position: 3
---

# Dependency Injection

We generally code with maintainability and scalability in mind, applying project-specific patterns
to a given function and improving the structure of our code. We must pay attention to our code, 
otherwise it can become a hidden problem. Let's look at a practical example:

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
- Makes Unit Tests more difficult, as you would not be able to create `XPTOEmail()` Fake/Mock instance.
- Entirely dependent on the functioning of an external class.

We call it "Dependency Coupling" when we use an outer class in this way, because the *Client* class
is totally dependent on the functioning of the **XPTOEmail** object.

To break a class's bond with its dependency, we generally prefer to "inject" the dependency instances through a constructor, setters, or methods. That's what we call "Dependency Injection".

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
This way, we reduce the coupling **XPTOEmail** object has to the **Client** object.

We still have a problem with this implementation. Despite *cohesion*, the Client class has a dependency on an external source, and even being injected by constructor, replacing it with another email service would not be a simple task.
Our code still has coupling, but we can improve this using `interfaces`. Let's create an interface
to define a signature, or "contract" for the **sendEmail** method. With this in place, any class that implements this interface can be injected into the class **Client**:

```dart
abstract class EmailService {
  void sendEmail(String email, String title, String body);
}

class XPTOEmailService implements EmailService {

  final XPTOEmail xpto;
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

This object creation method solves coupling issues but may increase instance creation complexity, as we can see in the **Client** class. The **flutter_modular** Dependency Injection System solves this problem simply and effectively.

## Instance registration

The strategy for building an instance with its dependencies comprise register all objects in a module and
manufactures them on demand or in single-instance form(singleton). All instance registration process
is managed by [auto_injector](https://pub.dev/packages/auto_injector)

There are a few ways to build a Bind to register object instances:


- *injector.add*: Build an instance on demand (Factory).
- *injector.addSingleton*: Build an instance only once when the module starts.
- *injector.addLazySingleton*: Build an instance only once when prompted.
- *injector.addInstance*: Adds an existing instance.

We register the binds in **AppModule**:

```dart
class AppModule extends Module {
  @override
  void binds(i) {
    i.add(XPTOEmail.new);
    i.add<EmailService>(XPTOEmailService.new);
    i.addSingleton(Client.new);

    // Register with Key
    i.addSingleton(Client.new, key: 'OtherClient');
  }
  
  ...
}
```
The dependencies of these instances will be resolved automatically using the [auto_injector](https://pub.dev/packages/auto_injector) mechanisms.

To get a resolved instance use `Modular.get`:

```dart
final client = Modular.get<Client>();

// or set a default value
final client = Modular.get<Client>(defaultValue: Client());

// or use tryGet
Client? client = Modular.tryGet<Client>();

// or get with key
Client client = Modular.get(key: 'OtherCLient');
```

## Auto Dispose

The lifetime of a Bind singleton ends when its module 'dies'. But there are some objects that, by default, 
run an instance destruction routine and are automatically removed from memory. Here they are:

- Stream/Sink (Dart Native).
- ChangeNotifier/ValueNotifier (Flutter Native).

For registered objects that are not part of this list, we can use **BindConfig** or implement a **Disposable** interface on the instance where we want to run an algorithm before dispose:

**Using BindConfig**:

The dispose of an instance can be set directly in `Register` by implementing the `onDispose` property:

```dart
@override
void binds(i) {
  i.addSingleton<MyBloc>(MyBloc.new, config: BindConfig(
    onDispose: (bloc) => bloc.close(),
  ));
}
```

**Using Disposable interface**

Doing this does not require **BindConfig**, but creates a link between the package and the class.

```dart
class MyController implements Disposable {
  final controller = StreamController();

  @override
  void dispose() {
    controller.close();
  }
}
```


**flutter_modular** also offers a singleton removal option from the dependency injection system 
by calling the **Modular.dispose**() method even with an active module:

```dart
Modular.dispose<MySingletonBind>();
```

