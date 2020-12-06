import 'package:flutter/material.dart';

import '../../core/models/modular_router.dart';
import '../navigation/modular_page.dart';
import '../navigation/modular_router_delegate.dart';

final _pages = <String, List<ModularPage>>{};

class RouterOutletDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter> {
  final GlobalKey<NavigatorState> navigatorKey;

  final ModularRouterDelegate modularRouterDelegate;

  RouterOutletDelegate(this.modularRouterDelegate, this.navigatorKey) {
    _getPages();
  }

  List<ModularPage> pages = [];

  List<ModularPage> _getPages() {
    final newPages = routers
        .map(
            (router) => ModularPage(key: ValueKey(router.path), router: router))
        .toList();

    if (pages.isEmpty) {
      pages = newPages;
      return pages;
    } else if (newPages.isNotEmpty &&
        newPages.last.router.modulePath == pages.last.router.modulePath) {
      pages = newPages;
      return pages;
    }

    return pages;
  }

  List<ModularRouter> get routers =>
      modularRouterDelegate.currentConfiguration?.routerOutlet ?? [];

  @override
  Widget build(BuildContext context) {
    return pages.isEmpty
        ? Material()
        : Navigator(
            pages: _getPages(),
            onPopPage: (route, result) {
              notifyListeners();
              return route.didPop(result);
            },
          );
  }

  @override
  Future<void> setNewRoutePath(ModularRouter router) async {
    assert(false);
  }
}
