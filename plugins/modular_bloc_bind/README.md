
# modular_bloc_bind

Working only Modular 5.

Specific Bind to BLoC with auto-dispose and notifier:

```dart
@override
final List<Bind> binds = [
  BlocBind.singleton((i) => MyBloc()),
];
```

