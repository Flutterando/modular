---
sidebar_position: 1
---

# Welcome to Modular

**flutter_modular** gives a Flutter app a *structure*: it turns the two things that
couple an application — **Dependency Injection** and **Routes** — into small,
self‑contained **Modules**, and ties application **state to the route lifecycle** so
that ownership and disposal stop being your problem.

:::tip flutter_modular 7 is a ground‑up rewrite
The API on this page (and the whole **flutter_modular** section) describes **v7**. If
you are still on v6 or v5, see **(Legacy) Modular 6** / **(Legacy) Modular 5** in the
sidebar, and the [migration guide](./flutter_modular/migration.md) when you are ready
to upgrade.
:::

## What is Modular?

In a monolithic architecture the whole app is a single module. That is quick and
elegant for small apps, but a larger app built that way accrues technical debt in both
maintenance and scalability. By dividing the app **by scope** instead, we gain:

- Improved understanding of features.
- Fewer breaking changes.
- New, non‑conflicting features added in isolation.
- Fewer blind spots in the main business rules.
- Easier developer turnover.

Compare a typical MVC, where every layer is global:

### A typical MVC

    .
    ├── models                                  # All models
    │   ├── auth_model.dart
    │   ├── home_model.dart
    │   └── product_model.dart
    ├── controller                              # All controllers
    │   ├── auth_controller.dart
    │   ├── home_controller.dart
    │   └── product_controller.dart
    ├── views                                   # All views
    │   ├── auth_page.dart
    │   ├── home_page.dart
    │   └── product_page.dart
    ├── core                                    # Tools and utilities
    ├── app_widget.dart                         # Main Widget containing MaterialApp
    └── main.dart                               # runApp

…with the same app divided by scope, where each feature owns its own MVC:

### Structure divided by scope

    .
    ├── features                                 # All features / Modules
    │   ├─ auth                                  # Auth's MVC
    │   │  ├── auth_model.dart
    │   │  ├── auth_controller.dart
    │   │  └── auth_page.dart
    │   ├─ home                                  # Home's MVC
    │   │  ├── home_model.dart
    │   │  ├── home_controller.dart
    │   │  └── home_page.dart
    │   └─ product                               # Product's MVC
    │      ├── product_model.dart
    │      ├── product_controller.dart
    │      └── product_page.dart
    ├── core                                     # Tools and utilities
    ├── app_widget.dart                          # Main Widget containing MaterialApp
    └── main.dart                                # runApp

We call this **Smart Structure**: each feature keeps its own MVC, which alone solves
many scalability and maintainability problems. But two things stay *global* and fight
the structure — **routes** and **dependency injection**. Modular exists to scope
exactly those two. We group a feature's routes and injections into an object and call
it a **Module**.

## The architecture Modular pushes

Modular is opinionated on purpose. A few ideas run through the whole package:

- **A Module is DI + Routes.** Those are the two coupling factors in a Flutter app, and
  a [Module](./flutter_modular/module.md) makes exactly those visible. A module mounted
  at a `path` is a *feature*; a module without a path is *shared DI*.

- **State is page‑scoped, with a deterministic lifecycle.** A view model declared with
  [`provide`](./flutter_modular/state-management.md) is built when its page mounts and
  `dispose()`d when the page leaves the stack. Lifecycle becomes the framework's job —
  which is what lets Modular take weight off whatever "state management" you reach for.

- **The Single Source of Truth lives in a repository/service.** Durable truth is a
  root‑owned singleton registered in [DI](./flutter_modular/dependency-injection.md);
  view models are disposable, per‑page projections over it. They never *hold* the truth.

- **Routing reads like the web.** The URL mirrors the navigation **stack base**;
  `pushNamed` stacks a page that stays out of the URL (modal‑like); routes can be
  **relative** to where you are, resolved like directories. See
  [Navigation](./flutter_modular/navigation.md).

## Ready to get started?

Modular does something powerful — componentizing routes and dependency injection — and
does it simply. Head to [Getting started](./flutter_modular/start.md) and begin your
journey toward a smart structure.

## Common questions

- **Does Modular work with any state‑management approach?**
  Yes. The DI system is agnostic to the class it builds, including any reactivity. On
  top of that, Modular ships its own page‑scoped state (`ChangeNotifier`, streams,
  `Consumer`/`Selector`) so for many apps you need nothing else.

- **Can I use dynamic routes?**
  Yes — the route tree matches like the web: dynamic `:params`, query strings, relative
  paths, nested routes and persistent shells (`RouterOutlet`) are all supported. Use a
  route [guard](./flutter_modular/navigation.md#guards) to redirect (e.g. to a 404 or a
  login page).

- **Do I need a Module for every feature?**
  No. Create a module when a feature earns its own boundary — its own routes and
  injections — or keep small things in a parent module.

- **I'm writing pure Dart, not Flutter.**
  Use [`auto_injector`](https://pub.dev/packages/auto_injector) directly — it is the DI
  engine **flutter_modular** is built on.
