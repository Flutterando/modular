---
sidebar_position: 7
---

# Tests

Modular provides tools make unit testing and route and injection integration easier.
In this session we'll learn how to do this.

First you need add the **modular_test** to pubspec.yaml:
```yaml

dev_dependencies:
  modular_test: any

```

:::tip TIP

Flutter's CLI has a tool that makes package installation easier in the project. Use the command:

`flutter pub add --dev modular_test`

:::

## Route Test 

We can replace the navigation object with a Mock/Fake by injecting the **Modular.navigatorDelegate** property:

```dart
class ModularNavigateMock extends Mock implements IModularNavigator {}

void main(){
    final navigate = ModularNavigateMock();
    Modular.navigatorDelegate = navigate;
}
```

:::tip TIP

Prefer to use Mockito or Mocktail to create mocks.

:::

:::tip TIP

To get navigate History use Modular.navigatorDelegate.navigateHistory

:::

## Injection Test

The safest way possible to inject dependencies is to test if the **Bind** construction happens as expected, then
we'll need to check this through the test.

The **modular_test** package has some tools to initializing modules and replacing binds with
mock. Let's take look at the example below:

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

    setUp((){
        initModule(MyModule(), replaceBinds: [
            Bind.instance<Dio>(dioMock),
        ]);
    });
}
```

:::danger ATTENTION

In order for a bind to be eligible for replacement, the **Bind** MUST have
the type declared in the **Bind** constructor. (ex: Bind<MyObjectType\>());

:::
