import 'package:flutter/material.dart';

import '../../core/models/modular_router.dart';
import '../modular_base.dart';
import 'modular_page.dart';
import 'modular_router_delegate.dart';

class RouterOutletDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter> {
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

    if (modularRouterDelegate.routerOutlatPages.containsKey(path)) {
      final list = modularRouterDelegate.routerOutlatPages[path] ?? [];
      pages = [...list];
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return pages.isEmpty
        ? Material()
        : Navigator(
            pages: _getPages(),
            onPopPage: (route, result) {
              if (pages.length > 1) {
                final page = route.settings as ModularPage;
                final path = page.router.path;
                page.completePop(result);
                final trash = <String>[];
                modularRouterDelegate.injectMap.forEach((key, module) {
                  module.paths.remove(path);
                  if (module.paths.length == 0) {
                    module.cleanInjects();
                    trash.add(key);
                    Modular.debugPrintModular(
                        "-- ${module.runtimeType.toString()} DISPOSED");
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
  Future<void> setNewRoutePath(ModularRouter router) async {
    assert(false);
  }
}
