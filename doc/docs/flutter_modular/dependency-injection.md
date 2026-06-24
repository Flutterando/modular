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

## Sharing dependencies across modules

Put a dependency that many features need — a config, an HTTP client, a session — in
a **root‑owned** (path‑less) "core" module, and depend on it **by type** anywhere.
You never thread it by hand: a feature's own binds, and its page‑scoped
[`provide`](./state-management.md) binds, both resolve it from the graph.

```dart
// CORE (root-owned): the shared dependency, registered once
final coreModule = createModule(
  register: (c) => c.addInstance<ApiConfig>(ApiConfig('https://api.example')),
);

// FEATURE: its OWN bind depends on the core ApiConfig — supplied automatically
final ordersModule = createModule(
  path: '/orders',
  register: (c) => c
    ..add<OrdersGateway>(OrdersGateway.new)   // OrdersGateway(ApiConfig) ← from core
    ..route('/', child: (ctx, state) => const OrdersPage()),
);

final appModule = createModule(
  register: (c) => c
    ..module(coreModule)     // included once at the root → visible to every feature
    ..module(ordersModule),  // takes NO parameters; resolves ApiConfig by type
);
```

You include the shared module **once at the root** — there is no need to re‑import it
in each feature (simpler than Angular's per‑feature `SharedModule`). Because the binds
are root‑owned, every feature sees them.

:::info Precedence — local shadows the core
If a feature registers its **own** bind of the same type, that local bind wins; the
core bind is the fallback. So a feature can override a shared default for itself
without affecting the rest of the app.
:::

:::note Requires 7.1.0+
Resolving a core dependency from a feature's **module‑level** bind needs
flutter_modular **7.1.0** (`auto_injector >= 2.2.0`). Page‑scoped `provide` binds
resolved the core in earlier versions too.
:::

## Async bootstrap (Hive, SharedPreferences, a DB connection)

`register` is **synchronous**, but some shared dependencies need an `await` to come up
— opening a Hive box, reading `SharedPreferences`, connecting a database. The idiom is
to do that `await` **once**, in a builder that *returns the module*, and capture the
ready instances in its closure. `main` stays thin and features take no parameters:

```dart
Future<Module> buildCoreModule() async {
  await Hive.initFlutter();
  final box = await Hive.openBox<dynamic>('app');     // awaited once, here
  return createModule(
    register: (c) => c
      // the raw box stays private in the closure — expose the CONTRACT
      ..addInstance<SettingsRepository>(HiveSettingsRepository(box)),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final core = await buildCoreModule();               // one await, one instance
  runApp(ModularApp(module: buildAppModule(core), child: const AppRoot()));
}

Module buildAppModule(Module core) => createModule(
  register: (c) => c
    ..module(core)            // shared, root-owned — features resolve it by type
    ..module(ordersModule),   // no parameters threaded in
);
```

Blocking on the bootstrap once, then registering the *ready* instances with
`addInstance`, keeps the rest of the app synchronous — no loading states sprinkled
through your widgets. Combined with cross‑module resolution above, `ordersModule`'s
binds resolve `SettingsRepository` from the core with **zero** parameter threading.

:::warning Build the async module once
`buildCoreModule()` returns a **new** module each call, and composition dedups by
identity — so call it **once** and reference that single instance. Calling it twice
would open the Hive box twice and register two distinct modules.
:::

## Next

- Bind state to a page's lifecycle → [State management](./state-management.md)
- Use dependencies in guards → [Navigation › Guards](./navigation.md#guards)
