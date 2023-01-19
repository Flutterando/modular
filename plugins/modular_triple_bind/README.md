# modular_triple_bind

Working only Modular 5.

Specific Bind to Triple's Store with auto-dispose and notifier:

```dart
@override
final List<Bind> binds = [
  TripleBind.singleton((i) => MyStore()),
];
```