---
sidebar_position: 4
---

# Navigation

Modular's routing is built on Navigator 2.0 and matches paths like the web: static
segments, dynamic `:params`, query strings, nested routes and relative paths. You
navigate from any widget through extensions on `BuildContext`.

## Declaring routes

Routes are declared on a module's context with `c.route`:

```dart
final productsModule = createModule(
  path: '/products',
  register: (c) {
    c
      ..route('/', child: (ctx, state) => const ProductListPage())
      ..route('/:id', child: (ctx, state) => ProductDetailPage(id: state['id']!));
  },
);
```

The full `route` signature:

```dart
c.route(
  String path, {
  required ModularWidgetBuilder child,        // (BuildContext, RouteState) => Widget
  void Function(Scoped scoped)? provide,       // page-scoped state — see State management
  void Function(ModularContext c)? children,   // nested routes — see Nested routes
  List<ModularGuard>? guards,                  // redirects — see below
  TransitionType transition,                   // material | fade | none
});
```

## RouteState

Every route `child` receives a `RouteState` — an immutable snapshot of the current
route:

```dart
c.route('/product/:id', child: (ctx, state) {
  final id = state['id'];                 // path param, shorthand for state.params['id']
  final ref = state.query['ref'];         // query string ?ref=...
  final extra = state.arguments;          // object passed via pushNamed(arguments:)
  return ProductDetailPage(id: id!);
});
```

| Member | What it is |
|---|---|
| `state.uri` | the full resolved `Uri` (path + query) |
| `state.params` | path params from the match, e.g. `{'id': '42'}` |
| `state['id']` | shorthand for `state.params['id']` |
| `state.query` | query parameters (`?a=1&b=2`) |
| `state.arguments` | the object passed at navigation time (not in the URL) |

You can also read the current route from **outside** a route builder (e.g. a shell's
active‑tab highlight) with `context.routeState()`. It is **reactive** by default — the
widget rebuilds when the app navigates, so route‑aware chrome derives from the route
instead of mirroring it in local state. Pass `listen: false` to read it in a callback
without subscribing.

## Navigating

The navigation verbs are extension methods on `BuildContext`:

```dart
context.pushNamed('/products/42');   // stack a page on top
context.navigate('/home');           // replace the whole stack (reset history)
context.replace('/login');           // replace just the top route
context.pop(result);                 // pop, delivering a result to the awaiting pushNamed
```

| Method | Effect |
|---|---|
| `pushNamed<T>(path, {arguments})` | Pushes a page; returns a `Future<T?>` completed by the matching `pop(result)`. |
| `navigate(path, {arguments})` | Replaces the whole stack and **resets history**. The v7 unification of 6.x's `navigate` + `pushNavigate`. |
| `replace<T>(path, {arguments})` | Replaces the **top** route (no back to the replaced one). |
| `pop<T>([result])` | Pops the top route, completing its `pushNamed` future with `result`. |
| `maybePop<T>([result])` | Pops only if there is something to pop; returns whether it did. |
| `canPop()` | Whether `pop` would do anything. |
| `popUntil(predicate)` | Pops until `predicate(RouteState)` holds. |
| `popAndPushNamed<T>(path, {result, arguments})` | Pops (delivering `result`), then pushes. |
| `pushNamedAndRemoveUntil<T>(path, predicate, {arguments})` | Pushes, then removes routes beneath it until `predicate` holds. |

### The URL reflects the stack *base*

This is the v7 routing model: the URL mirrors the **base** of the navigation stack, not
its top. So `navigate(...)` — which replaces the stack base — **changes the URL**, while
`pushNamed(...)` stacks a page **modal‑like** that stays **out of** the URL. Use
`navigate` for "go here and own the address" (tabs, top‑level destinations) and
`pushNamed` for "stack a detail/modal on top of where I am".

:::note
Inside a [`RouterOutlet`](./nested-routes.md), these verbs target the nearest outlet, so
the parent shell persists. Otherwise they target the root navigator.
:::

## Relative routes

A path without a leading `/` is **relative to the route the context is on**, resolved
like a directory:

```dart
// On /home:
context.pushNamed('dashboard');    // → /home/dashboard   (bare or ./ = one level deeper)
context.pushNamed('./dashboard');  // → /home/dashboard
context.pushNamed('../settings');  // → /settings         (.. climbs a level)
context.pushNamed('/login');       // → /login            (leading / = absolute)
```

This improves on 6.x's raw `Uri.resolve`, which treated `/home` as a *file* and turned
`dashboard` into `/dashboard` (dropping `home`). Modular treats the current location as
a directory, so a bare reference goes *inside* it. Query and fragment on the reference
are preserved (`item?ref=x`).

## Passing arguments and getting results

`arguments` carries an arbitrary object to the target route, recovered through
`RouteState.arguments`; the `Future` returned by `pushNamed` delivers a result back via
`pop`:

```dart
// Caller — pass an object, await a result:
final saved = await context.pushNamed<bool>(
  '/args/editor',
  arguments: EditorArgs(title: 'Draft'),
);

// Target route — read the object defensively:
c.route('/args/editor', child: (ctx, state) {
  final args = state.arguments;
  if (args is! EditorArgs) {
    return const Scaffold(body: Center(child: Text('Open this from the Arguments page.')));
  }
  return EditorPage(args: args);
});

// Inside the editor — return a result:
context.pop(true);
```

:::warning arguments are not in the URL
Unlike `:id` path params, `arguments` is **not** part of the URL. A deep link or a web
refresh on `/args/editor` arrives with `arguments == null`, so always read it
defensively. Use path params or query for anything that must survive a refresh.
:::

## Guards

A **guard** is a pure function `String? Function(RouteState)`: return a **redirect path**
to send the user elsewhere, or `null` to allow navigation. Guards run **before** the
page is shown.

```dart
c.route(
  '/settings/secret',
  guards: [
    // Reads DI at guard-eval time via inject<T>(); a redirect is an absolute path.
    (state) => inject<AppSession>().unlocked ? null : '/home/settings',
  ],
  child: (ctx, state) => const SecretPage(),
);
```

Guards are a list, evaluated in order — the first one that returns a path wins and
redirects. Reach dependencies inside a guard with
[`inject<T>()`](./dependency-injection.md#resolving-with-injectt). A guard redirect is an
**absolute** destination (there is no current context to be relative to). Use a guard to
gate authenticated areas, or to redirect unknown paths to a 404 page.

## Transitions

Set a route's page transition with `transition:`:

```dart
c.route('/details', transition: TransitionType.fade, child: ...);
```

`TransitionType` is `material` (the default), `fade`, or `none` (instant).

## Next

- Persistent shells and tabs → [Nested routes & RouterOutlet](./nested-routes.md)
- Page‑scoped view models → [State management](./state-management.md)
