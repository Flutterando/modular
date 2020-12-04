import 'package:flutter/material.dart';

import '../../core/models/modular_router.dart';
import '../../core/modules/child_module.dart';
import '../interfaces/modular_navigator_interface.dart';
import '../modular_base.dart';
import 'modular_page.dart';
import 'modular_route_information_parser.dart';

class ModularRouterDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter>
    implements
        IModularNavigator {
  final GlobalKey<NavigatorState> navigatorKey;
  final ModularRouteInformationParser parser;
  final Map<String, ChildModule> injectMap;

  ModularRouterDelegate(this.navigatorKey, this.parser, this.injectMap);

  NavigatorState get navigator => navigatorKey.currentState!;

  List<ModularPage> _pages = [];

  @override
  ModularRouter? get currentConfiguration => _pages.last.router;

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
    print('setNewRoutePath: ${router.routerOutlet.length}');

    final page = ModularPage(
      key: ValueKey('url:${router.path}'),
      router: router,
    );
    if (_pages.isEmpty) {
      _pages.add(page);
    } else {
      _pages.last.completePop(null);
      _pages.last = page;
    }

    rebuildPages();
  }

  @override
  Future<void> navigate(String routeName,
      {arguments, bool linked = false}) async {
    print('navigate: $routeName');
    var router =
        await parser.selectRoute(linked ? modulePath + routeName : routeName);
    router = router.copyWith(args: router.args?.copyWith(data: arguments));
    setNewRoutePath(router);
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    if (route.isFirst) {
      rebuildPages();
      return false;
    }

    final page = route.settings as ModularPage;
    final path = page.router.path;
    page.completePop(result);
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

  @override
  Future<T> pushNamed<T extends Object>(String routeName,
      {Object? arguments, bool linked = false}) async {
    var router =
        await parser.selectRoute(linked ? modulePath + routeName : routeName);
    router = router.copyWith(args: router.args?.copyWith(data: arguments));
    final page = ModularPage<T>(
      key: UniqueKey(),
      router: router,
    );
    _pages.add(page);
    rebuildPages();
    return await page.waitPop();
  }

  @override
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO? result,
      Object? arguments,
      bool linked = false}) async {
    var router =
        await parser.selectRoute(linked ? modulePath + routeName : routeName);
    router = router.copyWith(args: router.args?.copyWith(data: arguments));
    final page = ModularPage(
      key: UniqueKey(),
      router: router,
    );

    _pages.last.completePop(result);
    _pages.last = page;
    rebuildPages();
    return await page.waitPop();
  }

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO? result,
      Object? arguments,
      bool linked = false}) async {
    _pages.last.completePop(result);
    _pages.removeLast();
    return await pushNamed<T>(routeName, arguments: arguments, linked: linked);
  }

  @override
  bool canPop() {
    return navigator.canPop();
  }

  @override
  Future<bool> maybePop<T extends Object>([T? result]) =>
      navigator.maybePop(result);

  @override
  void pop<T extends Object>([T? result]) => navigator.pop(result);

  @override
  void popUntil(bool Function(Route) predicate) =>
      navigator.popUntil(predicate);

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
      String newRouteName, bool Function(Route) predicate,
      {Object? arguments, bool linked = false}) {
    popUntil(predicate);
    return pushNamed<T>(newRouteName, arguments: arguments, linked: linked);
  }

  @override
  String get modulePath => currentConfiguration?.routerOutlet.isEmpty == true
      ? currentConfiguration?.modulePath ?? '/'
      : currentConfiguration?.routerOutlet.last.modulePath ?? '/';

  @override
  String get path => currentConfiguration?.routerOutlet.isEmpty == true
      ? currentConfiguration?.path ?? '/'
      : currentConfiguration?.routerOutlet.last.path ?? '/';

  @override
  String get localPath => path.replaceFirst(modulePath, '');

  @override
  Future<T?> push<T extends Object>(Route<T> route) {
    return navigator.push<T>(route);
  }
}
