---
sidebar_position: 4
---

# Watch

Modular also has an InheritedWidget instance that can use the `dependsOn` API of [BuildContext].
This way, the developer can recover binds and, if it is a supported reactivity, will watch the modifications
changing the state of the widget in question.

The `watch()` method was added to [BuildContext] through extensions, making access easy.
```dart
class Body extends StatelessWidget {
  Widget build(BuildContext context){
    final notifier = context.watch<ValueNotifier>();
    return Text('${notifier.value}')
  }
}
```

Supported reactivities are:
- [Listenable](https://api.flutter.dev/flutter/foundation/Listenable-class.html)

Used in `ChangeNotifier/ValueNotifier` classes and in RxNotifier.

- [Stream](https://api.dart.dev/stable/2.15.0/dart-async/Stream-class.html)

Used in StreamController.

:::tip TIP

In addition to the **context.watch()** method, the read-only **context.read()** method has been added.
It's the same as using **Modular.get()**, but this addition helps projects that are being migrated
**Provider**.

:::

## With selectors

Sometimes binds are not a supported reactivity, but one of their properties can be.
As in the case of BLoC, where the Stream is available through a `bloc.stream` property;

We can add a selection through an anonymous function indicating which property is a supported reactivity to be watched:

```dart
class Body extends StatelessWidget {
  Widget build(BuildContext context){
    final bloc = context.watch<CounterBloc>((bloc) => bloc.stream);
    return Text('${bloc.state}')
  }
}
```

Note that the use of the selector does not change on bind return.

We can also use selectors for Triple objects, which have their own selectors for each of their segments:
See the Triple documentation for more details [by clicking here](https://triple.flutterando.com.br/docs/getting-started/using-flutter-triple#selectors):

```dart
class OnlyErrorWidget extends StatelessWidget {
  Widget build(BuildContext context){
    // changes with store.setError();
    final store = context.watch<MyTripleStore>((store) => store.selectError);
    return Text('${store.error}')
  }
}
```

It's also possible to configure a selector directly in bind:

```dart
@override
final List<Bind> binds = [
  //notifier return stream or listenable to use context.watch()
  Bind.singleton((i) => MyBloc(), selector: (bloc) => bloc.stream),
];
```

:::tip TIP

Existem `Bind` pré-configurados para BLoC e Triple.
Veja os packages [modular_bloc_bind](https://pub.dev/packages/modular_bloc_bind) e [modular_triple_bind](https://pub.dev/packages/modular_triple_bind)

:::