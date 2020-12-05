import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_page.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_router_delegate.dart';

import '../../core/models/modular_router.dart';

class RouterOutletDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final ModularRouterDelegate modularRouterDelegate;

  RouterOutletDelegate(this.modularRouterDelegate);

  List<ModularRouter> get routers =>
      modularRouterDelegate.currentConfiguration?.routerOutlet ?? [];

  @override
  Widget build(BuildContext context) {
    return routers.isEmpty
        ? Material()
        : Navigator(
            key: navigatorKey,
            pages: routers
                .map((router) =>
                    ModularPage(key: ValueKey(router.path), router: router))
                .toList(),
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
