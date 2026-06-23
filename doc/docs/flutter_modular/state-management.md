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
            ..add<RealtimeConnection>(RealtimeConnection.new)
            ..addChangeNotifier<ProductDetailViewModel>(ProductDetailViewModel.new)
            ..addStream<int>(_viewersStream);
        },
        child: (ctx, state) => ProductDetailPage(id: state['id']!),
      );
  },
);
```

The rule is **`addChangeNotifier`** (a reactive view model) and **`addStream`**
(stream‑backed state); **`add`** registers a plain non‑reactive object. The `Scoped`
registrar (`s`) offers:

| Method | For | Reactive? | Disposed on unmount? |
|---|---|---|---|
| `addChangeNotifier<T>(ctor)` | a `ChangeNotifier` view model | ✅ via `watch`/`read` | ✅ `dispose()` |
| `addStream<T>(create)` | stream‑backed state | ✅ as `StreamValue<T>` | ✅ cancels the subscription |
| `add<T>(ctor)` | a non‑reactive object (socket, use‑case, config) | ❌ | ✅ if it implements `Disposable` |

Reactivity and lifecycle are **independent**: a thing can have either, both, or neither.
For reactive objects that don't fit the two rules above — a **BLoC**, a **Cubit**, a
controller exposing a `Listenable` — there are two escape hatches,
[`addStreamable` and `addListenable`](#exceptions-addstreamable-and-addlistenable).

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

### add — a non‑reactive resource

For something that needs lifecycle but no reactivity — a connection, a subscription
manager, a use‑case holding a handle. It is built as a per‑page singleton, so a view
model can **inject the same instance**. If it implements `Disposable`, it is
`dispose()`d on exit — `add` **always** checks for `Disposable`:

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

## Exceptions: addStreamable and addListenable

`addChangeNotifier` and `addStream` cover the common cases. When an object's reactivity
lives on a **property** — its `stream`, or a `Listenable` it exposes — and you want to
expose the **object itself** (to read its synchronous state and call its methods), reach
for these two escape hatches. Each takes a factory, a selector for the reactive source,
and a (required) dispose callback:

- `addStreamable<T>(ctor, (t) => t.stream, (t) => t.close())` — reactivity is a `Stream`.
  `context.watch<T>()` returns the object; rebuilds fire on each emission.
- `addListenable<T>(ctor, (t) => t.someListenable, (t) => t.dispose())` — reactivity is a
  `Listenable` property.

```dart
// A controller that is NOT a ChangeNotifier but exposes one:
class SearchController {
  final ValueNotifier<String> query = ValueNotifier('');
  void dispose() => query.dispose();
}

provide: (s) => s.addListenable<SearchController>(
  SearchController.new,
  (c) => c.query,        // the rebuild trigger
  (c) => c.dispose(),    // cleanup on unmount
);
```

:::note
Prefer `addChangeNotifier`/`addStream`. Use `addStreamable`/`addListenable` only when the
reactive source is a property of the object you want to expose.
:::

## BLoC and Cubit

A **BLoC** or **Cubit** is exactly the streamable case: it exposes a synchronous `state`,
a `stream` of changes, and an async `close()`. Register it with `addStreamable` —
`context.watch<T>()` returns the **BLoC/Cubit** itself, so you read `state` directly and
rebuilds are driven by its stream:

```dart
// CounterCubit is a Cubit from the `bloc` package.
route(
  '/counter',
  provide: (s) => s.addStreamable<CounterCubit>(
    CounterCubit.new,
    (c) => c.stream,
    (c) => c.close(),
  ),
  child: (ctx, state) {
    final counter = ctx.watch<CounterCubit>(); // the Cubit itself
    return Text('${counter.state}');           // read its synchronous state
  },
);
```

flutter_modular has **no dependency on the `bloc` package** — `addStreamable` takes the
`stream` and `close` as callbacks. To make this a one‑liner, add a small extension on
`Scoped` in your app. Because both **BLoC** and **Cubit** extend `BlocBase` (which has
`.stream` and `.close()`), a single `addBloc` covers both:

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Registers a page-scoped BLoC or Cubit: reactive via its stream, closed on unmount.
extension BlocScoped on Scoped {
  void addBloc<B extends BlocBase<Object?>>(B Function() create) =>
      addStreamable<B>(create, (b) => b.stream, (b) => b.close());
}
```

```dart
// Now registering any BLoC or Cubit is one line:
provide: (s) => s.addBloc<CounterCubit>(CounterCubit.new),
```

:::tip
With the extension above, `addBloc<MyBloc>(MyBloc.new)` works for both **BLoC** and
**Cubit** — one line to get a page‑scoped, auto‑closed, reactive instance.
:::

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

`context.select<T, R>` is the **method‑based twin** of `Selector` — call it inside
`build` to subscribe to a derived value; the widget rebuilds only when that value
changes (compared with `==`). It mirrors `context.select` from **provider**, so
migrating is a near drop‑in:

```dart
// Inside build(): rebuilds only when `cart.items.length` changes.
final count = context.select<CartViewModel, int>((cart) => cart.items.length);
return Badge(label: Text('$count'));
```

:::note
Like in provider, only call `context.select` from `build` — never in `initState` or
`didChangeDependencies`.
:::

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

Implement it and register with `add` (page‑scoped) — Modular builds it in the
page‑local injector and calls `dispose()` on unmount. Feature‑module binds that
implement `Disposable` (or `ChangeNotifier`) are likewise disposed when the feature
leaves the stack; see [DI lifecycle](./dependency-injection.md#bind-lifecycle).

## Why this is the architecture

- **One home for the truth.** Repositories/services are root‑owned singletons; a view
  model reads them and never becomes a competing source of truth.
- **No floating state.** A VM exists exactly as long as its page; leaving disposes it.
- **State management gets lighter.** Lifecycle and provision are the framework's job, so
  whatever reactivity you choose has less to carry.
