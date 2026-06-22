import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// A PERSISTENT SHELL built on `RouterOutlet` — the bottom bar stays mounted
/// while the body swaps. Tab taps call `outlet.navigate(...)` (replace the
/// outlet's sub-stack — a tab switch, no history); pushing from inside a tab
/// stacks INSIDE the same outlet, so the shell persists there too.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  /// Counts shell builds from scratch — the example test asserts it stays 1
  /// across tab switches, proving the shell truly persists.
  static int inits = 0;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  // Drives the body outlet directly — the bottom bar is a SIBLING of the
  // outlet, so it reaches it via this key rather than `RouterOutlet.of`.
  final _outlet = GlobalKey<RouterOutletState>();

  // Absolute tab paths: the bottom bar drives the outlet through a GlobalKey
  // (not `context`), so there's no current-location to be relative to — the
  // shell names its own mount. The dashboard module is mounted at
  // `/home/dashboard`.
  static const _tabs = [
    '/home/dashboard',
    '/home/dashboard/search',
    '/home/dashboard/profile',
  ];

  @override
  void initState() {
    super.initState();
    DashboardShell.inits++;
  }

  @override
  Widget build(BuildContext context) {
    // The highlight is DERIVED from the route, never a stored copy: a deep link
    // to a non-default tab (or any navigation) lights the right destination
    // because `routeState()` rebuilds this when the URL changes. The route is
    // the single source of truth — the bottom bar just reads it. `lastIndexWhere`
    // so the most specific tab wins (every path starts with the Feed base).
    final path = context.routeState().uri.path;
    final selected = _tabs.lastIndexWhere(
      (t) => path == t || path.startsWith('$t/'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RouterOutlet(key: _outlet),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        // A tab tap just navigates the outlet — no local state to flip. The
        // resulting URL change rebuilds this and re-derives the highlight.
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
