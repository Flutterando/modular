import 'package:flutter_modular/flutter_modular.dart';

import 'dashboard_shell.dart';
import 'pages/feed_page.dart';
import 'pages/item_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';

/// ---------------------------------------------------------------------------
/// DASHBOARD FEATURE — the canonical `RouterOutlet` case: a PERSISTENT SHELL
/// (a bottom bar) whose body swaps.
///
/// The shell route renders a `DashboardShell` containing a `RouterOutlet`; its
/// `children` are the tabs, rendered INSIDE that outlet. This is the one place
/// `RouterOutlet` is for — `module(...)` flattens routes (no outlet); here we
/// declare the outlet EXPLICITLY because we want chrome that persists.
/// ---------------------------------------------------------------------------
final dashboardModule = createModule(
  path: '/dashboard',
  register: (c) {
    c.route(
      '/',
      child: (ctx, state) => const DashboardShell(),
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
