import 'package:flutter/material.dart';

import '../../core/errors/errors.dart';
import '../../core/interfaces/child_module.dart';
import '../../core/interfaces/modular_route.dart';
import '../modular_base.dart';

bool _firstParse = false;

class ModularRouteInformationParser extends RouteInformationParser<ModularRoute> {
  @override
  Future<ModularRoute> parseRouteInformation(RouteInformation routeInformation) async {
    late final String path;
    if (!_firstParse) {
      if (routeInformation.location == null || routeInformation.location == '/') {
        // ignore: invalid_use_of_visible_for_testing_member
        path = initialRouteDeclaratedInMaterialApp;
      } else {
        path = routeInformation.location!;
      }

      _firstParse = true;
    } else {
      // ignore: invalid_use_of_visible_for_testing_member
      path = routeInformation.location ?? initialRouteDeclaratedInMaterialApp;
    }

    final route = await selectRoute(path);
    return route;
  }

  @override
  RouteInformation restoreRouteInformation(ModularRoute router) {
    return RouteInformation(
      location: router.routerOutlet.isEmpty ? router.path : router.routerOutlet.last.path,
    );
  }

  ModularRoute? _searchInModule(ChildModule module, String routerName, Uri uri) {
    uri = uri.normalizePath();
    final routers = module.routes.map((e) => e.copyWith(currentModule: module)).toList();
    routers.sort((preview, actual) {
      return preview.routerName.contains('/:') ? 1 : 0;
    });
    for (var route in routers) {
      var r = _searchRoute(route, routerName, uri);
      if (r != null) {
        return r;
      }
    }
    return null;
  }

  ModularRoute? _normalizeRoute(ModularRoute route, String routerName, Uri uri) {
    ModularRoute? router;
    if (routerName == uri.path || routerName == "${uri.path}/") {
      router = route.module!.routes[0];
      if (router.module != null) {
        var _routerName = (routerName + route.routerName).replaceFirst('//', '/');
        router = _searchInModule(route.module!, _routerName, uri);
      } else {
        router = router.copyWith(uri: Uri.parse(routerName));
      }
    } else {
      router = _searchInModule(route.module!, routerName, uri);
    }
    return router;
  }

  ModularRoute? _searchRoute(ModularRoute route, String routerName, Uri uri) {
    final tempRouteName = (routerName + route.routerName).replaceFirst('//', '/');
    if (route.child == null) {
      var _routerName = ('$routerName${route.routerName}/').replaceFirst('//', '/');
      var router = _normalizeRoute(route, _routerName, uri);

      if (router != null) {
        router = router.copyWith(
          modulePath: router.modulePath == null ? '/' : tempRouteName,
          currentModule: route.currentModule,
          guards: [if (route.guards != null) ...route.guards!, if (router.guards != null) ...router.guards!],
        );

        if (router.transition == TransitionType.defaultTransition) {
          router = router.copyWith(
            transition: route.transition,
            customTransition: route.customTransition,
          );
        }
        if (route.module != null) {
          Modular.bindModule(route.module!, uri.toString());
        }
        return router;
      }
    } else {
      if (route.children.isNotEmpty) {
        for (var routeChild in route.children) {
          var r = _searchRoute(routeChild, tempRouteName, uri);
          if (r != null) {
            r.currentModule?.paths.remove(uri.toString());
            r = r.copyWith(modulePath: r.modulePath == route.modulePath ? tempRouteName : r.modulePath);
            route = route.copyWith(routerOutlet: [r], uri: uri.replace(path: tempRouteName));
            return route;
          }
        }
      }

      if (Uri.parse(tempRouteName).pathSegments.length != uri.pathSegments.length) {
        return null;
      }
      var parseRoute = _parseUrlParams(route, tempRouteName, uri);

      if (uri.path != parseRoute.uri?.path) {
        return null;
      }

      if (parseRoute.currentModule != null) {
        Modular.bindModule(parseRoute.currentModule!, uri.toString());
      }
      return parseRoute;
    }

    return null;
  }

  String resolveOutletModulePath(String tempRouteName, String outletModulePath) {
    var temp = '$tempRouteName/$outletModulePath'.replaceAll('//', '/');
    if (temp.characters.last == '/') {
      return temp.substring(0, temp.length - 1);
    } else {
      return temp;
    }
  }

  String prepareToRegex(String url) {
    final newUrl = <String>[];
    for (var part in url.split('/')) {
      var url = part.contains(":") ? "(.*?)" : part;
      newUrl.add(url);
    }

    return newUrl.join("/");
  }

  ModularRoute _parseUrlParams(ModularRoute router, String routeNamed, Uri uri) {
    if (routeNamed.contains('/:')) {
      final regExp = RegExp(
        "^${prepareToRegex(routeNamed)}\$",
        caseSensitive: true,
      );
      var r = regExp.firstMatch(uri.path);
      if (r != null) {
        var params = <String, String>{};
        var paramPos = 0;
        final routeParts = routeNamed.split('/');
        final pathParts = uri.path.split('/');

        //  print('Match! Processing $path as $routeNamed');

        for (var routePart in routeParts) {
          if (routePart.contains(":")) {
            var paramName = routePart.replaceFirst(':', '');
            if (pathParts[paramPos].isNotEmpty) {
              params[paramName] = pathParts[paramPos];
              routeNamed = routeNamed.replaceFirst(routePart, params[paramName]!);
            }
          }
          paramPos++;
        }
        uri = uri.replace(path: routeNamed);
        return router.copyWith(args: router.args!.copyWith(params: params, uri: uri), uri: uri);
      }

      uri = uri.replace(path: routeNamed);
      return router.copyWith(args: router.args!.copyWith(params: null, uri: uri), uri: uri);
    }

    uri = uri.replace(path: routeNamed);
    return router.copyWith(uri: uri, args: router.args!.copyWith(uri: uri));
  }

  ModularRoute? _searchWildcard(
    String path,
    ChildModule module,
  ) {
    ModularRoute? finded;

    final segments = path.split('/')..removeLast();
    final length = segments.length;
    for (var i = 0; i < length; i++) {
      final localPath = segments.join('/');
      final route = _searchInModule(module, "", Uri.parse(localPath.isEmpty ? '/' : localPath));
      if (route != null) {
        if (route.children.isNotEmpty && route.routerName != '/') {
          finded = route.children.last.routerName == '**' ? route.children.last : null;
        } else {
          finded = route.currentModule?.routes.last.routerName == '**' ? route.currentModule?.routes.last : null;
        }
        route.currentModule?.paths.remove(localPath);
        break;
      } else {
        segments.removeLast();
      }
    }

    return finded?.routerName == '**' ? finded : null;
  }

  Future<ModularRoute> selectRoute(String path, [ChildModule? module]) async {
    if (path.isEmpty) {
      throw Exception("Router can not be empty");
    }
    var uri = Uri.parse(path);
    var router = _searchInModule(module ?? Modular.initialModule, "", uri);

    if (router != null) {
      return canActivate(uri.path, router);
    } else {
      router = _searchWildcard(uri.path, module ?? Modular.initialModule);
      if (router != null) {
        return router;
      }
    }
    throw ModularError('Route \'${uri.path}\' not found');
  }

  Future<ModularRoute> canActivate(String path, ModularRoute router) async {
    if (router.guards?.isNotEmpty == true) {
      await _checkGuard(path, router);
    } else if (router.routerOutlet.isNotEmpty) {
      for (final r in router.routerOutlet) {
        await _checkGuard(path, r);
      }
    }

    return router;
  }

  Future<void> _checkGuard(String path, ModularRoute router) async {
    for (var guard in router.guards ?? []) {
      try {
        final result = await guard.canActivate(path, router);
        if (!result) {
          throw ModularError('$path is NOT ACTIVATE');
        }
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        throw ModularError('RouteGuard error. Check ($path) in ${router.currentModule.runtimeType}');
      }
    }
  }
}
