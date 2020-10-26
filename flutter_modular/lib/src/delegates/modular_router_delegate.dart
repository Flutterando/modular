import 'package:flutter/material.dart';
import '../../flutter_modular.dart';
import '../routers/modular_page.dart';

import 'modular_route_information_parser.dart';

class ModularRouterDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter> {
  final GlobalKey<NavigatorState> navigatorKey;
  final ModularRouteInformationParser parser;
  final Map<String, ChildModule> injectMap;

  ModularRouterDelegate(this.navigatorKey, this.parser, this.injectMap);

  ModularRouter _router;

  List<ModularPage> _pages = [];

  @override
  ModularRouter get currentConfiguration => _router;

  @override
  Widget build(BuildContext context) {
    return _pages.isEmpty
        ? Material()
        : Navigator(
            key: navigatorKey,
            pages: _pages,
            onPopPage: _onPopPage,
          );
  }

  @override
  Future<void> setNewRoutePath(ModularRouter router) async {
    final page = ModularPage(
      key: ValueKey('url:${router.path}'),
      router: router,
    );
    _pages.last = page;
    _router = router;

    rebuildPages();
  }

  Future<T> pushNamed<T extends Object>(String path, {Object arguments}) async {
    var router = parser.selectRoute(path);
    router = router.copyWith(args: router?.args?.copyWith(data: arguments));
    final page = ModularPage(
      router: router,
    );
    _pages.add(page);
    rebuildPages();
    return router.popRoute.future;
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result) || route.isFirst) {
      return false;
    }

    final page = route.settings as ModularPage;
    final path = page.router.path;
    page.router.popRoute.complete(result);
    _pages.removeLast();
    rebuildPages();

    final trash = <String>[];

    injectMap.forEach((key, module) {
      module.paths.remove(path);
      if (module.paths.length == 0) {
        module.cleanInjects();
        trash.add(key);
        Modular.debugPrintModular(
            "-- ${module.runtimeType.toString()} DISPOSED");
      }
    });

    for (final key in trash) {
      injectMap.remove(key);
    }

    return true;
  }

  void rebuildPages() {
    _pages = List.from(_pages);
    notifyListeners();
  }
}
