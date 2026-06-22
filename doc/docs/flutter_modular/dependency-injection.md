---
sidebar_position: 3
---

# Dependency injection

Modular's DI is powered by [`auto_injector`](https://pub.dev/packages/auto_injector).
You register constructors on a module's `ModularContext`; Modular resolves each
dependency's own constructor arguments from the graph automatically.

## Registering dependencies

Inside `register`, declare dependencies on the context (`c`):

```dart
final coreModule = createModule(
  register: (c) {
    c
      ..addSingleton<ProductService>(ProductService.new)
      ..addSingleton<ProductRepository>(ProductRepository.new) // gets ProductService injected
      ..addSingleton<AppSession>(AppSession.new);
  },
);
```

| Method | Builds | Lifetime |
|---|---|---|
| `add<T>(T Function(...))` | a **new** instance every time it is resolved | per resolution |
| `addSingleton<T>(T Function(...))` | once, **eagerly** at registration | one shared instance |
| `addLazySingleton<T>(T Function(...))` | once, on **first** resolution | one shared instance |
| `addInstance<T>(T value)` | nothing — registers an existing object | the value you pass |

You pass a **constructor reference** (e.g. `ProductRepository.new`), not an instance.
`auto_injector` reads its parameters and supplies them from the graph, so a repository
that takes a service in its constructor just works once both are registered.

## Resolving with `inject<T>()`

Constructor injection covers most needs — a class declares what it needs as constructor
parameters and the graph fills them in. When you need to reach a dependency from a place
that has no constructor — a route **guard**, a callback, a top‑level function — use
`inject<T>()`:

```dart
c.route(
  '/settings/secret',
  // inject<T>() reads DI at guard-eval time without exposing the injector object.
  guards: [(state) => inject<AppSession>().unlocked ? null : '/home/settings'],
  child: (ctx, state) => const SecretPage(),
);
```

`inject<T>()` resolves `T` from the **live** module graph (the injector object itself
stays private — Angular‑style). It throws a `StateError` if no Modular app has
bootstrapped yet, and because it reads the live graph, a feature module's dependencies
are reachable through it only while that feature is active.

## Bind lifecycle

*Where* a dependency is registered decides *how long* it lives — this is the other half
of the module `path` rule from [Modules](./module.md#a-modules-path-decides-what-it-is).

### Root‑owned (shared DI, never disposed)

Dependencies in a **path‑less** module are committed **eagerly** at bootstrap and live
for the whole app. They are your durable truth — repositories, services, sessions. A
leaving route never disposes them.

```dart
final coreModule = createModule(            // no path → root-owned
  register: (c) => c.addSingleton<ProductRepository>(ProductRepository.new),
);
```

### Feature‑scoped (bound on entry, disposed on exit)

Dependencies in a module **with a `path`** are bound lazily when the feature's **first
route enters** the stack, and disposed when its **last route leaves**. Disposal is
automatic for `ChangeNotifier`s and [`Disposable`](./state-management.md#disposable)s —
their `dispose()` is called.

```dart
final productsModule = createModule(
  path: '/products',                        // feature → binds disposed when it leaves
  register: (c) {
    c.add<ProductSearchController>(ProductSearchController.new);
    // ...routes...
  },
);
```

This mirrors how the "active path list" worked in 6.x: a feature's resources exist only
while the feature is on screen.

:::tip Where should a dependency live?
Put the **source of truth** (repositories, services, app session) in a root‑owned
module — it must outlive any single page. Put **feature‑local** machinery in the
feature's own module so it is cleaned up when the user leaves. For state that is 1:1
with a single page, prefer page‑scoped [`provide`](./state-management.md) over a module
bind.
:::

## Next

- Bind state to a page's lifecycle → [State management](./state-management.md)
- Use dependencies in guards → [Navigation › Guards](./navigation.md#guards)
