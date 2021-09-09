---
sidebar_position: 6
---

# Testes

O Modular fornece ferramentas e meio para facilitar os testes de unidade e integração de rotas e injeção.
Nessa sessão iremos aprender como fazer isso.

## Teste de rotas

Podemos substituir o objeto de navegação por um Mock/Fake injetando na propriedade **Modular.navigatorDelegate**:

```dart
class ModularNavigateMock extends Mock implements IModularNavigate {}

void main(){
    final navigate = ModularNavigateMock();
    Modular.navigatorDelegate = navigate;
}
```

:::tip TIP

Prefira usar o Mockito ou Mocktail para criar mocks.

:::

## Teste de Injeção

A forma segura de injetar dependências é testar se a construção do **Bind** acontece como se espera, então
precisaremos verificar isso atraves de testes.

O pacote **modular_test** entrega algumas ferramentas de inicialização de módulos e substituição de binds por
mock. Vejamos um exemplo:

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

Para que um bind possa está elegível para substituição, O **Bind** deve OBRIGATORIAMENTE ter
o tipo declarado no construtor do **Bind**. (ex: Bind<MyObjectType\>());

:::