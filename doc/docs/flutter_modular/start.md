---
sidebar_position: 1
---

# Getting started

This page builds the smallest possible Modular app — a counter — and explains each
piece. By the end you will have a module, an app bootstrap, and a page‑scoped view
model wired to a route.

## Install

Add **flutter_modular** to your project:

```bash
flutter pub add flutter_modular
```

That yields a dependency on the v7 line:

```yaml title="pubspec.yaml"
dependencies:
  flutter_modular: ^7.0.0
```

## A module is DI + Routes

Everything starts with a **Module**: the object that declares a scope's dependency
injection and its routes. Build one functionally with `createModule`:

```dart
import 'package:flutter_modular/flutter_modular.dart';

final appModule = createModule(
  register: (c) {
    c.route(
      '/',
      provide: (s) => s.addChangeNotifier<CounterViewModel>(CounterViewModel.new),
      child: (context, state) => const CounterPage(),
    );
  },
);
```

- `c.route('/', child: ...)` declares the route shown at `/`. The builder receives the
  `BuildContext` and a [`RouteState`](./navigation.md#routestate) (path params, query,
  arguments).
- `provide:` declares **page‑scoped state** for that route — here a `CounterViewModel`
  built when the page mounts and `dispose()`d when it leaves. More on that in
  [State management](./state-management.md).

:::tip Store modules in a `final`
Modules are deduplicated **by identity**. Keep each one in a top‑level `final` and
reference that same value everywhere it is composed — never `createModule(...)` twice
for the same logical module.
:::

## Bootstrap with ModularApp

`ModularApp` is the **first widget** of your app, sitting *above* `MaterialApp`. It
bootstraps the module once (collecting its routes + DI), owns the resulting injector,
and builds the router config:

```dart title="lib/main.dart"
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  runApp(
    ModularApp(
      module: appModule,
      child: const AppRoot(),
    ),
  );
}
```

The `child` is your `MaterialApp.router`. It reads the router config that `ModularApp`
built with `ModularApp.routerConfigOf(context)`:

```dart
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Smart App',
      routerConfig: ModularApp.routerConfigOf(context),
    );
  }
}
```

:::warning
`ModularApp` must be **above** the `MaterialApp.router` that reads
`routerConfigOf(context)`. That position is also what makes *app‑scoped* state
(theme, locale, session) possible — see [State management](./state-management.md#app-scoped-state).
:::

## The full counter

Putting it together — a complete, runnable app (this is the package's own
[`example`](https://github.com/Flutterando/modular/tree/master/example) in miniature):

```dart title="lib/main.dart"
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// A page-scoped view model (built per page mount, disposed on exit).
class CounterViewModel extends ChangeNotifier {
  int count = 0;

  void increment() {
    count++;
    notifyListeners();
  }
}

final appModule = createModule(
  register: (c) {
    c.route(
      '/',
      provide: (s) => s.addChangeNotifier<CounterViewModel>(CounterViewModel.new),
      child: (context, state) => const CounterPage(),
    );
  },
);

void main() {
  runApp(ModularApp(module: appModule, child: const AppRoot()));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'flutter_modular counter',
      routerConfig: ModularApp.routerConfigOf(context),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CounterViewModel>(); // reactive, page-scoped
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(child: Text('count: ${vm.count}')),
      floatingActionButton: FloatingActionButton(
        onPressed: context.read<CounterViewModel>().increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Configuring the root

`ModularApp` accepts a few options for the root navigator and the entry route:

```dart
ModularApp(
  module: appModule,
  initialRoute: '/home',                  // first route when the platform reports no deep link
  navigatorKey: myNavigatorKey,           // imperative access from outside the tree
  navigatorObservers: [myObserver],       // analytics, RouteObserver, …
  defaultTransition: TransitionType.fade, // app-wide fallback page transition
  child: const AppRoot(),
);
```

- **`initialRoute`** is shown when the platform hands you the bare `/` (app cold‑start
  with no deep link). A real entry URL — a web refresh on `/products/3`, an app link —
  overrides it.
- **`navigatorKey`** lets you reach the root `Navigator` imperatively (e.g. to show a
  global dialog). A fresh key is created if you omit it.
- **`navigatorObservers`** are attached to the root navigator.
- **`defaultTransition`** is the page transition every route inherits unless it sets its
  own `transition:`. Defaults to `TransitionType.material`. See
  [Transitions](./navigation.md#transitions).

:::tip Clean URLs on the web
Call `usePathUrlStrategy()` (from `package:flutter_web_plugins/url_strategy.dart`) at
the top of `main()` to get `/products/3` instead of `/#/products/3`. It is a no‑op off
the web.
:::

That is enough to run a Modular app. Next, learn how to grow it into multiple features
with [Modules](./module.md), or jump to [Navigation](./navigation.md).
