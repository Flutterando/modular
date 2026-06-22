---
sidebar_position: 5
---

# Nested routes & RouterOutlet

Some screens are **shells**: a persistent frame — a bottom bar, a sidebar, a tab bar —
whose body swaps as you move between sub‑destinations. Modular models this with nested
routes and a `RouterOutlet`.

## children vs. a flattened module

There are two ways routes nest, and they differ in one thing — whether a **shell
persists**:

- `c.module(other)` **flattens** the sub‑module's routes under its path. There is no
  visible frame around them; each route is a full page. This is the common case.
- A route's `children:` declares sub‑routes that render **inside a `RouterOutlet`** you
  place in that route's widget — so the parent stays mounted while the body changes.
  Use this when you want chrome that persists.

## A persistent shell

Declare the shell route with `children`, and render a `RouterOutlet` where the body
goes:

```dart
final dashboardModule = createModule(
  path: '/dashboard',
  register: (c) {
    c.route(
      '/',
      child: (ctx, state) => const DashboardShell(), // the frame (bottom bar)
      children: (sub) {
        sub
          ..route('/', child: (ctx, state) => const FeedPage())
          ..route('/search', child: (ctx, state) => const SearchPage())
          ..route('/profile', child: (ctx, state) => const ProfilePage())
          ..route('/item', child: (ctx, state) => const ItemPage());
      },
    );
  },
);
```

Mounted at `/dashboard`, the children resolve to `/dashboard` (Feed), `/dashboard/search`,
`/dashboard/profile`, `/dashboard/item`. The shell renders the matching child in its
outlet:

```dart
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});
  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  // The bottom bar is a SIBLING of the outlet, so it drives it through a key
  // rather than RouterOutlet.of(context).
  final _outlet = GlobalKey<RouterOutletState>();

  static const _tabs = [
    '/dashboard',
    '/dashboard/search',
    '/dashboard/profile',
  ];

  @override
  Widget build(BuildContext context) {
    // The active tab is DERIVED from the route — never stored. routeState()
    // rebuilds this when the URL changes, so a deep link lights the right tab.
    final path = context.routeState().uri.path;
    final selected = _tabs.lastIndexWhere((t) => path == t || path.startsWith('$t/'));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RouterOutlet(key: _outlet),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        // A tab tap just navigates the outlet — no local state to flip.
        onDestinationSelected: (i) => _outlet.currentState?.navigate(_tabs[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

`RouterOutlet` is a **real nested `Navigator`** with its own push/pop sub‑stack. The
shell (`DashboardShell`) builds once and stays mounted while the body swaps — its
`State` is preserved across tab switches.

## Tabs vs. stacking inside an outlet

The two navigation verbs mean different things inside an outlet:

- **`navigate(path)`** *replaces* the outlet's sub‑stack — a **tab switch** (no history
  to pop back through). That is what the bottom bar calls.
- **`pushNamed(path)`** *stacks* a page **inside** the same outlet, so the shell
  persists over it. Pop returns to the tab beneath.

From a widget **inside** the outlet you can use the `context` verbs directly — they
target the nearest outlet automatically:

```dart
// Inside a tab page — stacks /dashboard/item over the current tab, shell intact:
context.pushNamed('/dashboard/item');
```

The shell above drives the outlet through a `GlobalKey<RouterOutletState>` instead,
because the bottom bar is a **sibling** of the outlet (not a descendant), so there is no
enclosing outlet on its `context`.

## Back button on a shell's index page

A mounted module's index page is the sole entry of its outlet's nested `Navigator`, so
`AppBar`'s `automaticallyImplyLeading` cannot see the root stack underneath and shows no
arrow on its own. Use `context.canPop()` to decide whether to show one:

```dart
AppBar(
  leading: context.canPop()
      ? BackButton(onPressed: () => context.pop())
      : null,
);
```

## The URL follows the outlet

Switching tabs changes the URL (`/dashboard` → `/dashboard/search`) because the outlet
reports its **base** sub‑route to the root delegate. A `pushNamed` *inside* the outlet
leaves that base unchanged, so — consistent with the [stack‑base URL
model](./navigation.md#the-url-reflects-the-stack-base) — a stacked page stays out of the
URL while a tab switch shows up in it.

:::tip One outlet, one job
Reach for `RouterOutlet` only when you want a frame that **persists** across child
routes. If each destination is a full page with no shared chrome, plain `module(...)`
flattening is simpler.
:::
