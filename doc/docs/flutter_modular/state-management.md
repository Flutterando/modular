---
sidebar_position: 6
---

# State management

This is the architecture Modular pushes. State is **scoped** and has a **deterministic
lifecycle**: a view model is built when its page mounts and disposed when the page
leaves the stack. You don't own globals and you don't write `dispose` calls — the
framework does. The durable truth stays in a repository/service in
[DI](./dependency-injection.md); view models are disposable projections over it.

## Page‑scoped state with `provide`

Declare a route's state in its `provide` callback. Each registration becomes a factory
built in a **page‑local injector** at mount (its own dependencies resolved from the
module injector), provided to the subtree, and disposed at unmount.

```dart
final productsModule = createModule(
  path: '/products',
  register: (c) {
    c
      ..route(
        '/',
        provide: (s) => s.addChangeNotifier<ProductListViewModel>(ProductListViewModel.new),
        child: (ctx, state) => const ProductListPage(),
      )
      ..route(
        '/:id',
        provide: (s) {
          s
            ..addDisposable<RealtimeConnection>(RealtimeConnection.new)
            ..addChangeNotifier<ProductDetailViewModel>(ProductDetailViewModel.new)
            ..addStream<int>(_viewersStream);
        },
        child: (ctx, state) => ProductDetailPage(id: state['id']!),
      );
  },
);
```

The `Scoped` registrar (`s`) offers three kinds of registration:

| Method | For | Reactive? | Disposed on unmount? |
|---|---|---|---|
| `addChangeNotifier<T>(ctor)` | a `ChangeNotifier` view model | ✅ via `watch`/`read` | ✅ `dispose()` |
| `addDisposable<T>(ctor)` | a non‑reactive resource (socket, use‑case) | ❌ | ✅ `dispose()` |
| `addStream<T>(create)` | stream‑backed state | ✅ as `StreamValue<T>` | ✅ cancels the subscription |

Reactivity and lifecycle are **independent**: a thing can have either, both, or neither.

### addChangeNotifier — a reactive view model

The bound type is a `ChangeNotifier` (not a bare `Listenable`) precisely so disposal is
guaranteed. A page‑scoped VM reads the source of truth instead of holding it:

```dart
/// Page-scoped: 1:1 with the list view. Reads the repository (SSoT), doesn't own truth.
class ProductListViewModel extends ChangeNotifier {
  ProductListViewModel(this._repo);          // repo injected from the module graph
  final ProductRepository _repo;

  bool loading = true;
  List<Product> products = const [];

  Future<void> load() async {
    products = await _repo.getProducts();
    loading = false;
    notifyListeners();
  }
}
```

### addDisposable — a non‑reactive resource

For something that needs lifecycle but no reactivity — a connection, a subscription
manager, a use‑case holding a handle. It is built as a per‑page singleton, so a view
model can **inject the same instance**, and `dispose()`d on exit:

```dart
class RealtimeConnection implements Disposable {
  bool isOpen = true;

  @override
  void dispose() {
    isOpen = false; // closed when the detail page leaves the stack
  }
}
```

```dart
class ProductDetailViewModel extends ChangeNotifier {
  // The page's RealtimeConnection (same instance) injected alongside the repo.
  ProductDetailViewModel(this._repo, this._connection);
  final ProductRepository _repo;
  final RealtimeConnection _connection;
  bool get connected => _connection.isOpen;
}
```

### addStream — stream‑backed state

`addStream` exposes the latest value of a stream as a `StreamValue<T>`:

```dart
Stream<int> _viewersStream() =>
    Stream<int>.periodic(const Duration(seconds: 2), (i) => 40 + i);

// ...provide: (s) => s.addStream<int>(_viewersStream)...

// In the page:
final viewers = context.watch<StreamValue<int>>().value; // latest int, or null
```

## Reading state: `watch` and `read`

From any descendant of the page, reach a provided `Listenable`:

```dart
final vm = context.watch<ProductListViewModel>(); // rebuilds this widget on notify
context.read<ProductListViewModel>().load();       // reads without subscribing (callbacks)
```

- `context.watch<T>()` subscribes — the widget rebuilds when `T` notifies.
- `context.read<T>()` does **not** subscribe — use it in callbacks (`onPressed`) and
  one‑shot calls.

## Granular rebuilds: `Consumer` and `Selector`

`watch` rebuilds the whole widget that called it. To scope a rebuild to a sub‑tree, use
`Consumer`; to rebuild only when a *derived value* changes, use `Selector`:

```dart
// Rebuilds only this builder when the VM notifies:
Consumer<CartViewModel>(
  builder: (context, cart, child) => Text('${cart.items.length} items'),
);

// Rebuilds only when the selected value changes:
Selector<CartViewModel, int>(
  selector: (context, cart) => cart.items.length,
  builder: (context, count, child) => Badge(label: Text('$count')),
);
```

## App‑scoped state {#app-scoped-state}

Page‑scoped state lives *below* the `Navigator`, so it cannot rebuild the `MaterialApp`
itself. For app‑global state that drives **theme, locale, or session**, declare it on
`ModularApp.provide` — the very same `Scoped` mechanism, only anchored **above** the
`MaterialApp`:

```dart
void main() {
  runApp(
    ModularApp(
      module: appModule,
      provide: (s) => s.addChangeNotifier<ThemeController>(ThemeController.new),
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>(); // above the MaterialApp
    return MaterialApp.router(
      themeMode: theme.mode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: ModularApp.routerConfigOf(context),
    );
  }
}
```

```dart
class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;
  void toggle() {
    mode = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
```

Because it is anchored above the `Navigator`, a page deep in the tree can still reach it
with `context.read<ThemeController>().toggle()` — and the whole app re‑themes.

## Disposable {#disposable}

`Disposable` is the interface that opts a non‑reactive class into page‑scoped lifecycle:

```dart
abstract interface class Disposable {
  void dispose();
}
```

Implement it and register with `addDisposable` (page‑scoped) — Modular builds it in the
page‑local injector and calls `dispose()` on unmount. Feature‑module binds that
implement `Disposable` (or `ChangeNotifier`) are likewise disposed when the feature
leaves the stack; see [DI lifecycle](./dependency-injection.md#bind-lifecycle).

## Why this is the architecture

- **One home for the truth.** Repositories/services are root‑owned singletons; a view
  model reads them and never becomes a competing source of truth.
- **No floating state.** A VM exists exactly as long as its page; leaving disposes it.
- **State management gets lighter.** Lifecycle and provision are the framework's job, so
  whatever reactivity you choose has less to carry.
