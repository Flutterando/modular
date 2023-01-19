import 'package:flutter/material.dart';
import '../../../flutter_modular.dart';

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
  final List<NavigatorObserver>? observers;

  RouterOutletDelegate(
      this.path, this.modularRouterDelegate, this.navigatorKey, this.observers);

  List<ModularPage> _getPages() {
    return modularRouterDelegate.currentConfiguration
            ?.chapters(path)
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    final _pages = _getPages();
    return _pages.isEmpty
        ? const Material()
        : CustomNavigator(
            key: navigatorKey,
            modularBase: Modular,
            pages: _pages,
            observers: observers ?? [],
            onPopPage: modularRouterDelegate.onPopPage,
          );
  }

  @override
  Future<void> setNewRoutePath(ParallelRoute configuration) async {
    assert(false);
  }
}
