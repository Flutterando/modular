---
sidebar_position: 6
---

# Tests

Modular provides tools and means to facilitate unit testing and route and injection integration.
In this session we will learn how to do this.

## Route Test 

We can replace the navigation object with a Mock/Fake by injecting the **Modular.navigatorDelegate** property:

```dart
class ModularNavigateMock extends Mock implements IModularNavigate {}

void main(){
    final navigate = ModularNavigateMock();
    Modular.navigatorDelegate = navigate;
}
```

:::tip TIP

Prefer to use Mockito or Mocktail to create mocks.

:::

## Injection Test

The safe way to inject dependencies is to test if the **Bind** construction goes as expected, then
we will need to verify this through testing.

The **modular_test** package delivers some tools for initializing modules and replacing binds with
mock. Let's look at an example:

```dart {4,18}
class MyModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.factory<Dio>((i) => Dio())
    Bind.factory((i) => XPTOEmail(i()))
    Bind.factory<EmailService>((i) => XPTOEmailService(i()))
    Bind.singleton((i) => Client(i()))
  ];
}
... 
class DioMock extends Mock implements DioForNative {}

main(){
    final dioMock = DioMock();

    setUp(){
        initModule(MyModule(), replaceBinds: [
            Bind.instance<Dio>(dioMock),
        ]);
    }
}
```

:::danger ATTENTION

In order for a bind to be eligible for replacement, the **Bind** must MUST have
the type declared in the **Bind** constructor. (ex: Bind<MyObjectType\>());

:::