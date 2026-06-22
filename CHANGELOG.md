# Changelog

## 7.0.0-dev.1

Ground-up rewrite of flutter_modular. **Breaking:** the v6 API (`Module` with
`List<Bind> get binds` / `List<ModularRoute> get routes`, `Bind`, `ChildRoute`,
`ModuleRoute`, the global `Modular` facade, and the `modular_core` engine) is
replaced. v7 is a single, self-contained Flutter package (depends directly on
`auto_injector` + `web`; `modular_core` is gone).

- **Modules are DI + Routes only**, declared functionally with
  `createModule(register:)` and a flat `ModularContext` (`addSingleton`/`add*`,
  `route(path, child:, provide:, children:, guards:, transition:)`,
  `module(value, {at})` to include shared deps or mount submodules). Deduped by
  identity; path-less modules are root-owned (shared), path-bearing modules are
  features with their own DI lifecycle (bound on first route entry, disposed on
  last exit).
- **Navigator 2.0**, fully declarative: hierarchical route matching with
  `/:params`, `RouterOutlet` for persistent shells with their own nested stack,
  guards/redirects, transitions. `context.pushNamed`/`navigate`/`replace`/`pop`
  (+ `popUntil`/`popAndPushNamed`/`pushNamedAndRemoveUntil`). URL mirrors the
  stack base; pushes stay out of the URL by design. Relative routes resolve
  against the current location.
- **Page-scoped state** via `provide`: `addChangeNotifier` / `addStream` /
  `addDisposable` build state 1:1 with the view in a page-local injector and
  dispose it when the route leaves. Read with `context.watch`/`read`/`select`
  and the `Consumer`/`Selector` widgets. App-scoped state goes on
  `ModularApp(provide:)` (above `MaterialApp`).
- **`context.routeState()`** — reactive access to the current `RouteState`
  (uri + resolved params + arguments) for route-aware chrome.
- `inject<T>()` for runtime resolution where a constructor can't inject (e.g.
  route guards).

See [`example/`](example/) for a complete app exercising every feature.
