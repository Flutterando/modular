---
sidebar_position: 3
---

# Injeção de dependências

Geralmente escrevemos código pensando em manutenção e escalabilidade, aplicando padrões de projetos específicos
para determinada função e melhorando a estrutura do nosso código. Temos que nos atentar sempre pois, sorrateiramente,
o código pode ficar problemático. Vejamos o exemplo prático:

```dart
class Client {
  void sendEmail(String email, String title, String body){
    final xpto = XPTOEmail();
    xpto.sendEmail(email, title, body);
  }
}
```

Aqui temos uma classe **Client** com um método chamado **sendEmail()** executando a rotina de envio instanciando a
classe **XPTOEmail**.
Apesar de ser uma abordagem simples e funcional, ter uma classe instanciada dentro do método apresenta alguns problemas:

- Torna impossível a substituição da instancia `xpto`.
- Dificulta os Testes de unidade, pois não teria como criar uma instancia Fake/Mock do `XPTOEmail()`.
- Inteiramente dependente do funcionamento de uma classe externa.

Chamamos de "Acoplamento de dependências" quando usamos uma classe externa dessa forma, pois a classe *Client* 
depende totalmente do funcionamento do objeto **XPTOEmail**.

Para quebrar o vínculo de uma classe com sua dependência, geralmente preferimos "injetar" as instancias de dependências via construtor, setters ou métodos, e é isso que chamamos de "Injeção de Dependências".

Vamos corrigir a classe **Cliente** injetando via construtor a instancia de **XPTOEmail**:

```dart
class Client {

  final XPTOEmail xpto;
  Client(this.xpto);

  void sendEmail(String email, String title, String body){
    xpto.sendEmail(email, title, body);
  }
}
```
Dessa forma, diminuímos o acoplamento que o objeto **XPTOEmail** fazia no objeto **Client**.

Ainda temos um problema nessa implementação. Apesar a *coesão*, a classe Cliente tem uma dependência a uma fonte
externa, e mesmo sendo injetada via construtor, substituir por outro serviço de email não seria uma tarefa simples.
Ainda temos acomplamento nesse código, mas podemos melhorar isso usando `interfaces`. Vamos criar uma interface
que assine o método **sendEmail**. Com isso, toda classe que implementar essa interface pode ser injetada na class
**Client**:

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

Assim podemos criar implementações de quaisquer serviços de email. Para finalizar, vamos substituir a dependência do
XPTOEmail pela da interface EmailService:

```dart
class Client {

  final EmailService service;
  Client(this.service);

  void sendEmail(String email, String title, String body){
    service.sendEmail(email, title, body);
  }
}
```

Criamos agora a instância do **Client**:

```dart
//dependencies
final xpto = XPTOEmail();
final service = XPTOEmailService(xpto)

// instance
final client = Client(service);
```

Esse tipo de criação de objeto resolve o acoplamento mas pode aumentar a complexidade de criação de instância, como podemos ver na classe **Client**. O Sistema de injeção de dependência do **flutter_modular** resolve esse problema de forma simples e eficaz.

## Registro de instâncias

A estratégia para construir uma instância com suas dependências consiste em registrar todos os objetos em um módulo e 
fabrica-los sobre demanda ou em forma de instância única(singleton). A esse registro damos o nome de **Bind**.
Existe algumas formas de construir um Bind para registrar as instâncias de objetos:

- *Bind.singleton*: Constroi uma instância apenas uma vez quando o módulo inciar.
- *Bind.lazySingleton*: Constroi uma instância apenas uma vez quando for solicitado.
- *Bind.factory*: Constroi uma instância sobre demanda.
- *Bind.instance*: Adiciona uma instância já existente.

Registraremos os binds no **AppModule**:

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

Note que em vez da instância das dependências foi colocado um `i()`. Isso será responsável por resolver as
dependências automáticamente.

Para pegar uma instância resolvida use o `Modular.get`:

```dart
final client = Modular.get<Client>();

// or set a default value
final client = Modular.get<Client>(defaultValue: Client());
```

:::tip TIP

Um construtor padrão **Bind()** é o mesmo que **Bind.lazySingleton()**;

:::

## AsyncBind

O **flutter_modular** também consegue resolver dependências assincronas. Para isso, use **AsyncBind** em vez de **Bind**:

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

Precisamos agora transformar os AsyncBind em Bind síncronos para pode resolver as outras instâncias. Para isso,
usamos o **Modular.isModuleReady()** passando o tipo do módulo nas generics;
```dart
await Modular.isModuleReady<AppModule>();
```
Essa ação converterá todos os AsyncBinds em Binds síncronos e singletons.

:::tip TIP

Podemos pegar a instância assíncrona diretamente também sem precisar converter em um bind sincrono usando
**Modular.getAsync()**;

:::

## Dispose automático

A vida útil de um Bind singleton finaliza quando seu módulo morre. Mas existem alguns objetos que, por padrão, são 
executados por uma rotina de destruição da instância e removidos da memória automáticamente. São eles:

- Stream/Sink (Dart Native).
- ChangeNotifier/ValueNotifier (Flutter Native).
- Store (Triple Pattern).

Para objetos registrados que não fazem parte dessa lista, podemos implementar a interface **Disposable** na instância que queremos executar um algoritimo antes do dispose:

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

Como o BLoC é baseado em Streams, o memory release já efeito automaticamente.

:::

O **flutter_modular** também oferece uma opcão de remoção de singleton do sistema de injeção de dependência
mesmo com o módulo ativo chamando o método **Modular.dispose**():

```dart
Modular.dispose<MySingletonBind>();
```