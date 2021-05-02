import 'package:flutter/material.dart';

import '../../core/interfaces/modular_route.dart';
import '../modular_base.dart';
import 'custom_navigator.dart';
import 'modular_page.dart';
import 'modular_router_delegate.dart';

class RouterOutletDelegate extends RouterDelegate<ModularRoute>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRoute> {
  final GlobalKey<NavigatorState> navigatorKey;

  final ModularRouterDelegate modularRouterDelegate;
  late String path;

  RouterOutletDelegate(this.modularRouterDelegate, this.navigatorKey) {
    path = modularRouterDelegate.currentConfiguration!.path!;
    _getPages();
  }

  List<ModularPage> pages = [];

  List<ModularPage> _getPages() {
    if (modularRouterDelegate.currentConfiguration?.path != path) {
      return pages;
    }

    if (modularRouterDelegate.routerOutletPages.containsKey(path)) {
      final list = modularRouterDelegate.routerOutletPages[path] ?? [];
      pages = [
        ...list
      ];
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final _pages = _getPages();
    return _pages.isEmpty
        ? Material()
        : CustomNavigator(
            key: navigatorKey,
            pages: _pages,
            onPopPage: (route, result) {
              if (pages.length > 1) {
                final page = route.settings as ModularPage;
                final path = page.router.path;
                page.completePop(result);
                final trash = <String>[];
                modularRouterDelegate.injectMap.forEach((key, module) {
                  module.paths.remove(path);
                  if (module.paths.isEmpty) {
                    module.cleanInjects();
                    trash.add(key);
                    Modular.debugPrintModular("-- ${module.runtimeType.toString()} DISPOSED");
                  }
                });

                for (final key in trash) {
                  modularRouterDelegate.injectMap.remove(key);
                }
              }

              return route.didPop(result);
            },
          );
  }

  @override
  Future<void> setNewRoutePath(ModularRoute router) async {
    assert(false);
  }
}
