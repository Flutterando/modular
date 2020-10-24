import 'package:flutter/material.dart';

import '../../flutter_modular.dart';

class ModularRouteInformationParser
    extends RouteInformationParser<ModularRouter> {
  @override
  Future<ModularRouter> parseRouteInformation(
      RouteInformation routeInformation) async {
    final path = routeInformation.location;
    final route = selectRoute(path);
    return route;
  }

  @override
  RouteInformation restoreRouteInformation(ModularRouter router) {
    return RouteInformation(location: router.path);
  }

  ModularRouter _searchInModule(
      ChildModule module, String routerName, String path) {
    path = "/$path".replaceAll('//', '/');
    final routers =
        module.routers.map((e) => e.copyWith(currentModule: module)).toList();
    routers.sort((preview, actual) {
      return preview.routerName.contains('/:') ? 1 : 0;
    });
    for (var route in routers) {
      route = _searchRoute(route, routerName, path);
      if (route != null) {
        return route;
      }
    }
    return null;
  }

  ModularRouter _searchRoute(
      ModularRouter route, String routerName, String path) {
    final tempRouteName =
        (routerName + route.routerName).replaceFirst('//', '/');
    if (route.child == null) {
      var _routerName =
          ('$routerName${route.routerName}/').replaceFirst('//', '/');
      ModularRouter router;
      if (_routerName == path || _routerName == "$path/") {
        router = route.module.routers[0];
        if (router.module != null) {
          var _routerName =
              (routerName + route.routerName).replaceFirst('//', '/');
          router = _searchInModule(route.module, _routerName, path);
        }
      } else {
        router = _searchInModule(route.module, _routerName, path);
      }

      if (router != null) {
        router = router.copyWith(
          modulePath: router.modulePath == null ? '/' : tempRouteName,
          path: path,
        );

        if (router.transition == TransitionType.defaultTransition) {
          router = router.copyWith(
            transition: route.transition,
            customTransition: route.customTransition,
          );
        }
        Modular.bindModule(route.module, path);
        return router;
      }
    } else {
      if (_parseUrlParams(route, tempRouteName, path)) {
        Modular.bindModule(route.currentModule, path);
        return route.copyWith(path: path);
      }
    }

    return null;
  }

  String prepareToRegex(String url) {
    final newUrl = <String>[];
    for (var part in url.split('/')) {
      var url = part.contains(":") ? "(.*?)" : part;
      newUrl.add(url);
    }

    return newUrl.join("/");
  }

  bool _parseUrlParams(ModularRouter router, String routeNamed, String path) {
    if (routeNamed.split('/').length != path.split('/').length) {
      return false;
    }

    if (routeNamed.contains('/:')) {
      final regExp = RegExp(
        "^${prepareToRegex(routeNamed)}\$",
        caseSensitive: true,
      );
      var r = regExp.firstMatch(path);
      if (r != null) {
        final params = <String, String>{};
        var paramPos = 0;
        final routeParts = routeNamed.split('/');
        final pathParts = path.split('/');

        //  print('Match! Processing $path as $routeNamed');

        for (var routePart in routeParts) {
          if (routePart.contains(":")) {
            var paramName = routePart.replaceFirst(':', '');
            if (pathParts[paramPos].isNotEmpty) {
              params[paramName] = pathParts[paramPos];
              routeNamed =
                  routeNamed.replaceFirst(routePart, params[paramName]);
            }
          }
          paramPos++;
        }

        // print('Result processed $path as $routeNamed');

        if (routeNamed != path) {
          router.args = router.args.copyWith(params: null);
          return false;
        }
        router.args = router.args.copyWith(params: params);
        return true;
      }

      router.args = router.args.copyWith(params: null);
      return false;
    }

    return routeNamed == path;
  }

  ModularRouter selectRoute(String path, [ChildModule module]) {
    if (path.isEmpty) {
      throw Exception("Router can not be empty");
    }
    final route = _searchInModule(module ?? Modular.initialModule, "", path);
    return route;
  }
}
