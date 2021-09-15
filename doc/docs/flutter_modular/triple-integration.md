---
sidebar_position: 7
---

# Triple Pattern integration

The [Triple](https://triple.flutterando.com.br/docs/getting-started/using-flutter-triple) is integrated with **flutter_modular**,
and makes it easier to recognize the **Bind** in the **flutter_triple** Builders (**ScopedBuilder**, **TripleBuilder**).

Exemple without **flutter_modular**:
```dart
ScopedBuilder<MyStore, Exception, String>(
    store: counter,
    onState: (context, state) => Text('$state'),
    onError: (context, error) => Text(error.toString()),
    onLoading: (context) => CircularProgressIndicator(),
);
```
Exemple with **flutter_modular**:
```dart
ScopedBuilder<MyStore, Exception, String>(
    onState: (context, state) => Text('$state'),
    onError: (context, error) => Text(error.toString()),
    onLoading: (context) => CircularProgressIndicator(),
);
```

:::info INFO

Triple(SSP) is a state management standard created and maintained by Flutterando.

[Click here](https://triple.flutterando.com.br) to know more!

:::
