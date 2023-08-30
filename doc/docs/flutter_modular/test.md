---
sidebar_position: 7
---

# Tests

Modular provides tools make unit testing and route and injection integration easier.
In this session we'll learn how to do this.

## Route Test 

We can replace the navigation object with a Mock/Fake by injecting the **Modular.navigatorDelegate** property:

```dart
class ModularNavigateMock extends Mock implements IModularNavigator {}

class MyController {
  editUser(){
    ... logic...
    Modular.to.navigate('/edit-user');
  }
}

void main(){
    final navigator = ModularNavigateMock();
    Modular.navigatorDelegate = navigate;

    test('edit user', (){
      when(() => navigator.navigate(any())).thenAnswer((_) => Future.value());
      final controller = Controller();

      controller.editUser();

      verify(() => navigator.navigate(any())).called(1);

    });
}

```

:::tip TIP

Prefer to use Mockito or Mocktail to create mocks.

:::


## Injection Test

The safest possible way to inject dependencies is to test that the instances resolve as expected, then
we will need to verify this via unit tests.

The `Modular` has tools that help you change an instance for a mock in order to test the integration of several layers.

```dart {4,18}
class MyModule extends Module {
  @override
  void binds(i){
    i.addInstance<Dio>(Dio());
    i.add(XPTOEmail.new);
    i.add<EmailService>(XPTOEmailService.new);
    i.addSingleton(Client.new);
  }
}
... 
class DioMock extends Mock implements DioForNative {}

main(){
    final dioMock = DioMock();
    // Start Module
    Modular.bindModule(AppModule());
    // replace Dio instance by DioMock instance
    Modular.replaceInstance<Dio>(dioMock);
    // Reset Stub after test ends
    tearDown(() => reset(client));

}
```

