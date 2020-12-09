import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/modular_router.dart';
import '../../core/modules/child_module.dart';
import '../interfaces/modular_navigator_interface.dart';
import '../modular_base.dart';
import 'custom_navigator.dart';
import 'modular_page.dart';
import 'modular_route_information_parser.dart';

class ModularRouterDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter>
    implements
        IModularNavigator {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ModularRouteInformationParser parser;
  final Map<String, ChildModule> injectMap;

  ModularRouterDelegate(this.parser, this.injectMap) {
    SystemChannels.navigation.setMethodCallHandler((call) async {
      if ('pushRouteInformation' == call.method) {
        navigate(call.arguments['location']);
      }
    });
  }

  NavigatorState get navigator => navigatorKey.currentState!;

  List<ModularPage> _pages = [];
  final routerOutlatPages = <String, List<ModularPage>>{};

  @override
  ModularRouter? get currentConfiguration =>
      _pages.isEmpty ? null : _pages.last.router;

  @override
  Widget build(BuildContext context) {
    return _pages.isEmpty
        ? Material()
        : CustomNavigator(
            key: navigatorKey,
            pages: _pages,
            onPopPage: _onPopPage,
          );
  }

  @override
  Future<void> setNewRoutePath(ModularRouter router,
      [bool execRebuild = true]) async {
    final page = ModularPage(
      key: ValueKey('url:${router.path}'),
      router: router,
    );
    if (_pages.isEmpty) {
      _pages.add(page);
    } else {
      for (var p in _pages) {
        p.completePop(null);
        removeInject(p.router.path!);
        for (var r in p.router.routerOutlet) {
          removeInject(r.path!);
        }
      }

      _pages = [page];
    }

    if (execRebuild) {
      rebuildPages();
    }
  }

  String resolverPath(String routeName, String path) {
    final uri = Uri.parse(path);
    return uri.resolve(routeName).path;
  }

  @override
  Future<void> navigate(String routeName,
      {arguments, bool linked = false}) async {
    if (routeName == path) {
      return;
    }

    routeName = resolverPath(routeName, path);

    var router =
        await parser.selectRoute(linked ? modulePath + routeName : routeName);
    router = router.copyWith(args: router.args?.copyWith(data: arguments));
    setNewRoutePath(router, false);
    if (router.routerOutlet.isNotEmpty) {
      routerOutlatPages[router.path!] = router.routerOutlet
          .map((e) => ModularPage(key: ValueKey(e.path), router: e))
          .toList();
    }
    rebuildPages();
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
    final path = page.router.path!;
    page.completePop(result);
    removeInject(path);
    for (var r in page.router.routerOutlet) {
      removeInject(r.path!);
    }
    _pages.removeLast();
    rebuildPages();

    return true;
  }

  removeInject(String path) {
    final trash = <String>[];

    injectMap.forEach((key, module) {
      module.paths.remove(path);
      if (path.characters.last == '/') {
        module.paths.remove('$path/'.replaceAll('//', ''));
      }
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
  }

  void rebuildPages() {
    _pages = List.from(_pages);
    notifyListeners();
  }

  @override
  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments, bool forRoot = false}) async {
    routeName = resolverPath(routeName, path);
    var router = await parser.selectRoute(routeName);
    router = router.copyWith(args: router.args?.copyWith(data: arguments));

    if (router.routerOutlet.isNotEmpty) {
      final outletRouter = router.routerOutlet.last.copyWith(
        args: router.args?.copyWith(data: arguments),
      );
      final page = ModularPage<T>(
        key: UniqueKey(),
        router: outletRouter,
      );

      if (forRoot) {
        _pages.add(page);
        rebuildPages();
        return await page.waitPop();
      } else {
        routerOutlatPages[router.path!]?.add(page);
        currentConfiguration?.routerOutlet.add(outletRouter);
        notifyListeners();
        final result = await page.waitPop();
        routerOutlatPages[router.path!]?.removeLast();
        currentConfiguration?.routerOutlet.removeLast();
        notifyListeners();
        return result;
      }
    } else {
      final page = ModularPage<T>(
        key: UniqueKey(),
        router: router,
      );
      _pages.add(page);
      rebuildPages();
      return await page.waitPop();
    }
  }

  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments,
      bool forRoot = false}) async {
    routeName = resolverPath(routeName, path);
    var router = await parser.selectRoute(routeName);
    router = router.copyWith(args: router.args?.copyWith(data: arguments));

    if (router.routerOutlet.isNotEmpty) {
      final outletRouter = router.routerOutlet.last.copyWith(
        args: router.args?.copyWith(data: arguments),
      );
      final page = ModularPage<T>(
        key: UniqueKey(),
        router: outletRouter,
      );

      if (forRoot) {
        final lastPage = _pages.last;
        _pages.last = page;
        rebuildPages();
        final result = await page.waitPop();
        lastPage.completePop(result);
        return result;
      } else {
        final lastPage = routerOutlatPages[router.path!]?.last;
        routerOutlatPages[router.path!]?.last = page;
        currentConfiguration?.routerOutlet.last = outletRouter;
        notifyListeners();
        final result = await page.waitPop();
        lastPage!.completePop(result);
        notifyListeners();
        return result;
      }
    } else {
      final page = ModularPage<T>(
        key: UniqueKey(),
        router: router,
      );

      final lastPage = _pages.last;
      _pages.last = page;
      rebuildPages();
      final result = await page.waitPop();
      lastPage.completePop(result);
      return result;
    }
  }

  @override
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments,
      bool forRoot = false}) async {
    routeName = resolverPath(routeName, path);
    var router = await parser.selectRoute(routeName);
    if (!forRoot && router.routerOutlet.isNotEmpty) {
      routerOutlatPages[router.path!]?.last.completePop(result);
    } else {
      _pages.last.completePop(result);
      _pages.removeLast();
    }

    return await pushNamed<T>(routeName,
        arguments: arguments, forRoot: forRoot);
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
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
      String newRouteName, bool Function(Route) predicate,
      {Object? arguments, bool forRoot = false}) {
    popUntil(predicate);
    return pushNamed<T>(newRouteName, arguments: arguments, forRoot: forRoot);
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
