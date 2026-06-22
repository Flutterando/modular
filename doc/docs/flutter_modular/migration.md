---
sidebar_position: 8
---

# Migrating from v6 to v7

**flutter_modular 7 is a ground‑up rewrite.** The concepts you know — modules, routes,
dependency injection — are all here, but the API changed shape: a module is now a small
functional declaration, navigation moved onto `BuildContext`, and state is built into the
route lifecycle. This guide maps the old API to the new one.

:::note
Looking for **v5 → v6**? That guide is preserved under **(Legacy) Modular 6** in the
sidebar.
:::

## At a glance

| Area | v6 | v7 |
|---|---|---|
| Module | `class X extends Module { binds(i){} routes(r){} }` | `final x = createModule(register: (c) {...})` |
| Child route | `r.child('/', child: (ctx) => P())` | `c.route('/', child: (ctx, state) => P())` |
| Submodule | `r.module('/x', module: XModule())` | `c.module(xModule)` (module declares its own `path`) |
| Redirect route | `RedirectRoute('/x', to: '/y')` | a [guard](./navigation.md#guards) returning `'/y'` |
| Wildcard / 404 | `WildcardRoute(child: ...)` | a guard that redirects unknown paths |
| Register a dep | `i.addSingleton(X.new)` in `binds` | `c.addSingleton<X>(X.new)` in `register` |
| Resolve a dep | `Modular.get<X>()` | `inject<X>()` or constructor injection |
| Navigate | `Modular.to.pushNamed('/x')` | `context.pushNamed('/x')` |
| Replace stack | `Modular.to.navigate('/x')` | `context.navigate('/x')` |
| Pop | `Modular.to.pop()` | `context.pop()` |
| Route args | `Modular.args.data` / `args.params['id']` | `state.arguments` / `state['id']` |
| Router config | `Modular.routerConfig` | `ModularApp.routerConfigOf(context)` |
| Navigator key / observers / initial route | `Modular.setNavigatorKey/...` | `ModularApp(navigatorKey:, navigatorObservers:, initialRoute:)` |
| Page state | bring‑your‑own | `route(provide:)` + `context.watch`/`read` |

## Modules

The `binds`/`routes` method pair becomes a single `register` callback, and the module is
a `final` value rather than a class you instantiate.

```dart title="v6"
class HomeModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(HomeStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const HomePage());
    r.module('/products', module: ProductsModule());
  }
}
```

```dart title="v7"
final homeModule = createModule(
  path: '/home',
  register: (c) {
    c
      ..addSingleton<HomeStore>(HomeStore.new)
      ..route('/', child: (ctx, state) => const HomePage())
      ..module(productsModule); // productsModule declares path: '/products'
  },
);
```

Two shifts to note:

- A submodule now declares its **own** `path` (`createModule(path: '/products', ...)`),
  so the parent just lists `c.module(productsModule)`. Override at the include site with
  `c.module(productsModule, at: '/catalog')` only when you must.
- Reference each module by its `final` value — composition
  [dedups by identity](./module.md#creating-a-module).

## Routes, redirects and wildcards

`ChildRoute` → `c.route`. The builder now receives `(context, state)` instead of just
`context`, and `RedirectRoute`/`WildcardRoute` are replaced by **guards**:

```dart title="v6"
r.child('/product/:id', child: (context) => ProductPage(id: Modular.args.params['id']));
r.redirect('/old', to: '/new');
r.wildcard(child: (context) => const NotFoundPage());
```

```dart title="v7"
c.route('/product/:id', child: (ctx, state) => ProductPage(id: state['id']!));
c.route('/old', guards: [(state) => '/new'], child: (ctx, state) => const SizedBox());
// Unknown paths: redirect via a guard on a catch‑all you control.
```

## Dependency injection

`Bind` types are gone; register constructors directly on the context. See
[Dependency injection](./dependency-injection.md).

```dart title="v6"
void binds(i) {
  i.addSingleton(Repository.new);
  i.add(ApiClient.new);
}
// later: final repo = Modular.get<Repository>();
```

```dart title="v7"
register: (c) {
  c
    ..addSingleton<Repository>(Repository.new)
    ..add<ApiClient>(ApiClient.new);
}
// later: final repo = inject<Repository>(); // or constructor injection
```

## Navigation

The global `Modular.to` facade becomes extensions on `BuildContext`:

```dart title="v6"
Modular.to.pushNamed('/products/42', arguments: data);
Modular.to.navigate('/home');
Modular.to.pop(result);
```

```dart title="v7"
context.pushNamed('/products/42', arguments: data);
context.navigate('/home');
context.pop(result);
```

Read params/arguments from the `state` your builder receives instead of `Modular.args`.
Note the v7 [URL model](./navigation.md#the-url-reflects-the-stack-base): `pushNamed`
stacks modal‑like (out of the URL) and `navigate` owns the URL.

## Bootstrap

`ModularApp` now owns the router config and the root‑navigator options that used to be
set through global setters:

```dart title="v6"
void main() {
  Modular.setInitialRoute('/home');
  Modular.setNavigatorKey(myKey);
  Modular.setObservers([myObserver]);
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}

class AppWidget extends StatelessWidget {
  Widget build(context) => MaterialApp.router(routerConfig: Modular.routerConfig);
}
```

```dart title="v7"
void main() {
  runApp(
    ModularApp(
      module: appModule,
      initialRoute: '/home',
      navigatorKey: myKey,
      navigatorObservers: [myObserver],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  Widget build(context) =>
      MaterialApp.router(routerConfig: ModularApp.routerConfigOf(context));
}
```

## State management

If you used a separate state package wired through `Modular.get`, consider moving
page‑local state into the route's [`provide`](./state-management.md) so it is built and
disposed with the page, and keeping app‑global state (theme/session) on
`ModularApp.provide`. The durable source of truth stays a root‑owned singleton in DI.
