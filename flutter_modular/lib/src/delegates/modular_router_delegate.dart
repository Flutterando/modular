import 'package:flutter/material.dart';
import '../../flutter_modular.dart';
import '../routers/modular_page.dart';

import 'modular_route_information_parser.dart';
import 'transitionDelegate.dart';

final List<ModularRouter> _routers = [];

class ModularRouterDelegate extends RouterDelegate<ModularRouter>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularRouter> {
  final GlobalKey<NavigatorState> navigatorKey;
  final ModularRouteInformationParser parser;
  final Map<String, ChildModule> injectMap;

  TransitionDelegate transitionDelegate = NoAnimationTransitionDelegate();

  ModularRouterDelegate(this.navigatorKey, this.parser, this.injectMap);

  @override
  ModularRouter get currentConfiguration => _routers.last;

  @override
  Widget build(BuildContext context) {
    if (_routers.isEmpty) {
      _routers.add(parser.selectRoute(Modular.initialRoute));
    }

    return Navigator(
      key: navigatorKey,
      transitionDelegate: transitionDelegate,
      pages: _routers.map((router) => ModularPage(router)).toList(),
      onPopPage: _onPopPage,
    );
  }

  @override
  Future<void> setNewRoutePath(ModularRouter router) async {
    if (Modular.initialRoute != router.path) {
      transitionDelegate = DefaultTransitionDelegate();
      final index = _routers.indexOf(router);
      if (index == -1) {
        _routers.add(router);
      } else {
        _routers[index] = router;
        transitionDelegate = NoAnimationTransitionDelegate();
      }

      notifyListeners();
    }
  }

  Future<T> pushNamed<T extends Object>(String path, {Object arguments}) async {
    final router = parser.selectRoute(path);
    setNewRoutePath(
        router.copyWith(args: router?.args?.copyWith(data: arguments)));
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }
    final path = _routers.last.path;
    _routers.removeLast();
    notifyListeners();

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
}
