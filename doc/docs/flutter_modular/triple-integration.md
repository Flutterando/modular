---
sidebar_position: 7
---

# Integração com o Triple

O [Triple](https://triple.flutterando.com.br/docs/getting-started/using-flutter-triple) está integrado ao **flutter_modular**,
e isso facilita o reconhecimento do **Bind** nos Builders do **flutter_triple** (**ScopedBuilder**, **TripleBuilder**).

Exemplo sem o **flutter_modular**:
```dart
ScopedBuilder<MyStore, Exception, String>(
    store: counter,
    onState: (context, state) => Text('$state'),
    onError: (context, error) => Text(error.toString()),
    onLoading: (context) => CircularProgressIndicator(),
);
```
Exemplo com o **flutter_modular**:
```dart
ScopedBuilder<MyStore, Exception, String>(
    onState: (context, state) => Text('$state'),
    onError: (context, error) => Text(error.toString()),
    onLoading: (context) => CircularProgressIndicator(),
);
```

:::info INFO

O Triple(SSP) é um padrão de gerenciamento de estado criado e mantido pela Flutterando.

[Click aqui](https://triple.flutterando.com.br) para conhecer!

:::