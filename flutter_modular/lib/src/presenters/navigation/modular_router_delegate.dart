import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/errors/errors.dart';
import '../../core/interfaces/modular_navigator_interface.dart';
import '../../core/interfaces/modular_route.dart';
import '../../core/interfaces/module.dart';
import '../../core/models/modular_arguments.dart';
import '../modular_base.dart';
import 'custom_navigator.dart';
import 'modular_page.dart';
import 'modular_route_information_parser.dart';

class ModularRouterDelegate extends RouterDelegate<ModularRoute>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRoute>
    implements
        IModularNavigator {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ModularRouteInformationParser parser;
  final Map<String, Module> injectMap;

  ModularRouterDelegate(this.parser, this.injectMap);
  NavigatorState get navigator => navigatorKey.currentState!;

  List<ModularPage> _pages = [];
  final routerOutletPages = <String, List<ModularPage>>{};
  ModularArguments? _arguments;

  @override
  ModularRoute? get currentConfiguration => _pages.isEmpty ? null : _pages.last.router;

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
  Future<void> setNewRoutePath(ModularRoute router, [@deprecated bool replaceAll = true]) async {
    _arguments = router.args;
    final page = ModularPage(
      key: ValueKey('url:${router.uri?.path ?? router.path}'),
      router: router,
    );

    if (_pages.isEmpty) {
      _pages.add(page);
    } else {
      // Fix navigate function to don't replace a route of the same module and
      // replace all external modules
      final _lastPageModule = _pages.last;
      final routeIsInModule = _lastPageModule.router.modulePath == page.router.modulePath;

      if (routeIsInModule) {
        _pages.add(page);
      } else {
        for (var p in _pages) {
          p.completePop(null);
          removeInject(p.router.path!);
          for (var r in p.router.routerOutlet) {
            removeInject(r.path!);
          }
        }
        if (replaceAll) {
          _pages = [page];
        } else if (_pages.last.router.path != router.path) {
          _pages.last = page;
        } else {
          _pages.last.router.routerOutlet.clear();
          _pages.last.router.routerOutlet.add(router.routerOutlet.last);
        }
      }
    }

    if (router.routerOutlet.isNotEmpty) {
      routerOutletPages[router.path!] = router.routerOutlet.map((e) => ModularPage(key: ValueKey(e.path), router: e)).toList();
    }

    rebuildPages();
  }

  String resolverPath(String routeName, String path) {
    final uri = Uri.parse(path);
    return '${uri.resolve(routeName).toString()}';
  }

  @override
  Future<void> navigate(String routeName, {arguments, @deprecated bool replaceAll = true}) async {
    routeName = resolverPath(routeName, path);
    if (routeName == path) {
      return;
    }

    var router = await parser.selectRoute(routeName, arguments: arguments);
    _arguments = router.args;
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
      if (module.paths.isEmpty) {
        module.cleanInjects();
        trash.add(key);
        Modular.debugPrintModular("-- ${module.runtimeType.toString()} DISPOSED");
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
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments, bool forRoot = false}) async {
    routeName = resolverPath(routeName, path);
    var router = await parser.selectRoute(routeName, arguments: arguments);
    _arguments = router.args;

    if (router.routerOutlet.isNotEmpty) {
      final outletRouter = router.routerOutlet.last.copyWith(
        args: router.args.copyWith(data: arguments),
      );
      _arguments = outletRouter.args;
      final page = ModularPage<T>(
        key: UniqueKey(),
        router: outletRouter,
      );

      if (forRoot) {
        _pages.add(page);
        rebuildPages();
        return await page.waitPop();
      } else if (router.routerName != currentConfiguration?.routerName) {
        routerOutletPages[router.path!] = router.routerOutlet.map((e) => ModularPage(key: ValueKey(e.path), router: e)).toList();
        final rootPage = ModularPage<T>(
          key: UniqueKey(),
          router: router,
        );
        _pages.add(rootPage);
        rebuildPages();
        return await rootPage.waitPop();
      } else {
        routerOutletPages[router.path!]?.add(page);
        currentConfiguration?.routerOutlet.add(outletRouter);
        notifyListeners();
        final result = await page.waitPop();
        routerOutletPages[router.path!]?.removeLast();
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
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments, bool forRoot = false}) async {
    routeName = resolverPath(routeName, path);
    var router = await parser.selectRoute(routeName, arguments: arguments);
    _arguments = router.args;

    if (router.routerOutlet.isNotEmpty) {
      final outletRouter = router.routerOutlet.last.copyWith(
        args: router.args.copyWith(data: arguments),
      );
      _arguments = outletRouter.args;
      var page = ModularPage<T>(
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
        final routeOutletConf = currentConfiguration?.routerOutlet ?? [];
        ModularPage? lastPage;
        if (routeOutletConf.isEmpty) {
          throw ModularError('Prefer Modular.to.navigate()');
        } else {
          lastPage = routerOutletPages[router.path!]?.last;
          routerOutletPages[router.path!]?.last = page;
          currentConfiguration?.routerOutlet.last = outletRouter;
          notifyListeners();
        }

        final result = await page.waitPop();
        if (lastPage != null) {
          lastPage.completePop(result);
        }
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

      // Remove inject of replaced module on pushReplacementNamed()
      final _lastPagePath = lastPage.router.path;
      if (_lastPagePath != null) {
        removeInject(_lastPagePath);
        for (var r in lastPage.router.routerOutlet) {
          removeInject(r.path!);
        }
      }

      final result = await page.waitPop();
      lastPage.completePop(result);
      return result;
    }
  }

  @override
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments, bool forRoot = false}) async {
    routeName = resolverPath(routeName, path);
    var router = await parser.selectRoute(routeName, arguments: arguments);
    if (!forRoot && router.routerOutlet.isNotEmpty) {
      routerOutletPages[router.path!]?.last.completePop(result);
    } else {
      _pages.last.completePop(result);
      _pages.removeLast();
    }

    return await pushNamed<T>(routeName, arguments: arguments, forRoot: forRoot);
  }

  @override
  bool canPop() {
    return navigator.canPop();
  }

  @override
  Future<bool> maybePop<T extends Object>([T? result]) => navigator.maybePop(result);

  @override
  void pop<T extends Object>([T? result]) => navigator.pop(result);

  @override
  void popUntil(bool Function(Route) predicate) => navigator.popUntil(predicate);

  @override
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(String newRouteName, bool Function(Route) predicate, {Object? arguments, bool forRoot = false}) {
    popUntil(predicate);
    return pushNamed<T>(newRouteName, arguments: arguments, forRoot: forRoot);
  }

  @override
  String get modulePath => currentConfiguration?.routerOutlet.isEmpty == true ? currentConfiguration?.modulePath ?? '/' : currentConfiguration?.routerOutlet.last.modulePath ?? '/';

  @override
  String get path => currentConfiguration?.routerOutlet.isEmpty == true ? currentConfiguration?.path ?? '/' : currentConfiguration?.routerOutlet.last.path ?? '/';

  ModularArguments? get args => _arguments;

  @override
  String get localPath => path.replaceFirst(modulePath, '');

  @override
  Future<T?> push<T extends Object?>(Route<T> route) {
    return navigator.push<T>(route);
  }
}
