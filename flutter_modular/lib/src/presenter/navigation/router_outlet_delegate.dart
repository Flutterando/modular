import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';

import 'custom_navigator.dart';
import 'modular_page.dart';
import 'modular_router_delegate.dart';

class RouterOutletDelegate extends RouterDelegate<ParallelRoute>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ParallelRoute> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final ModularRouterDelegate modularRouterDelegate;
  final String path;

  RouterOutletDelegate(this.path, this.modularRouterDelegate, this.navigatorKey);

  List<ModularPage> _getPages() {
    return modularRouterDelegate.currentConfiguration?.chapters(path).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final _pages = _getPages();
    return _pages.isEmpty
        ? Material()
        : CustomNavigator(
            key: navigatorKey,
            modularBase: Modular,
            pages: _pages,
            onPopPage: modularRouterDelegate.onPopPage,
          );
  }

  @override
  Future<void> setNewRoutePath(ParallelRoute router) async {
    assert(false);
  }
}
