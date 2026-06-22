---
sidebar_position: 2
---

# Modules & composition

A **Module** is the unit of structure in Modular: it declares a scope's **dependency
injection** and **routes**, and nothing else. The two things that couple a Flutter app
are exactly DI + Routes, so a module is the app's coupling map made explicit.

## Creating a module

Build a module functionally with `createModule`, and store it in a top‑level `final`:

```dart
import 'package:flutter_modular/flutter_modular.dart';

final homeModule = createModule(
  path: '/home',
  register: (c) {
    c.route('/', child: (ctx, state) => const HomePage());
  },
);
```

The `register` callback receives a `ModularContext` (`c`), the single surface a module
declares itself through:

| On `ModularContext` | Purpose |
|---|---|
| `c.route(path, child:, …)` | Declare a route (see [Navigation](./navigation.md)) |
| `c.module(other, {at})` | Include another module |
| `c.add<T>` / `addSingleton<T>` / `addLazySingleton<T>` / `addInstance<T>` | Register a dependency (see [DI](./dependency-injection.md)) |

:::warning Modules are deduplicated by identity
Composition dedups modules by **object identity**, so always reference the same `final`
value. Calling `createModule(...)` twice for the same logical module creates two
distinct objects and defeats the dedup.
:::

## A module's `path` decides what it is

This is the central idea of v7. Whether a module declares a `path` changes its meaning:

### A module **with** a `path` is a *feature*

Its routes are **flattened under that path**, and its dependencies are
**feature‑scoped** — bound when its first route enters the stack and disposed when its
last route leaves (covered in [DI lifecycle](./dependency-injection.md#bind-lifecycle)).

```dart
// Mounted at /products → these relative routes become /products and /products/:id.
final productsModule = createModule(
  path: '/products',
  register: (c) {
    c
      ..route('/', child: (ctx, state) => const ProductListPage())
      ..route('/:id', child: (ctx, state) => ProductDetailPage(id: state['id']!));
  },
);
```

A mount path is a **static prefix**: it must start with `/` and contain no dynamic
segment. Dynamic `:params` belong to the routes *inside* a module, not to where the
module mounts.

```dart
createModule(path: '/checkout', register: (_) {});  // ✅ ok
createModule(register: (_) {});                      // ✅ ok — no path (see below)
createModule(path: 'checkout', register: (_) {});    // ❌ AssertionError — must start with '/'
createModule(path: '/users/:id', register: (_) {});  // ❌ AssertionError — no ':param' in a mount path
```

### A module **without** a `path` is *shared DI*

Its dependencies are **root‑owned**: bound eagerly and never disposed — they live for
the whole app. This is where your Single Source of Truth belongs.

```dart
/// CORE — the shared data layer. Everything here is an app-wide singleton in this
/// route-less module, so it is root-owned and lives for the whole app.
final coreModule = createModule(
  register: (c) {
    c
      ..addSingleton<ProductService>(ProductService.new)
      ..addSingleton<ProductRepository>(ProductRepository.new)
      ..addSingleton<AppSession>(AppSession.new);
  },
);
```

## Composing modules

Use `c.module(...)` to include one module in another. A feature lists its sub‑features;
the root module is the whole app's composition:

```dart
/// THE ROOT MODULE — composition only. This file is the app's coupling map: which
/// modules exist and how they connect.
final appModule = createModule(
  register: (c) {
    c
      ..module(coreModule)   // shared DI (no path) → root-owned
      ..module(homeModule);  // feature (path '/home') → mounted there
  },
);
```

Each module declares its **own** `path`, so a parent usually just lists them:

```dart
final homeModule = createModule(
  path: '/home',
  register: (c) {
    c
      ..route('/', child: (ctx, state) => const HomePage())
      ..module(productsModule)   // → /home/products
      ..module(settingsModule)
      ..module(dashboardModule);
  },
);
```

Because `productsModule` is included under `homeModule` (mounted at `/home`), its routes
land at `/home/products` and `/home/products/:id`. Composition concatenates the paths,
just like the module tree mirrors the widget tree.

### Overriding the mount with `at:`

`at:` is the rare override of a module's own `path` at the include site — mount the same
module somewhere else:

```dart
c.module(productsModule, at: '/catalog'); // routes become /catalog, /catalog/:id
```

Most apps never need `at:`; let each module name its own mount.

## Feature vs. shell

`module(...)` **flattens** a sub‑module's routes under its path — there is no visible
shell wrapping them. When you want chrome that **persists** across child routes (a
bottom bar, a sidebar), declare a `RouterOutlet` explicitly inside a route's
`children`. See [Nested routes & RouterOutlet](./nested-routes.md).

## Next

- Register and resolve dependencies → [Dependency injection](./dependency-injection.md)
- Declare routes, params and guards → [Navigation](./navigation.md)
