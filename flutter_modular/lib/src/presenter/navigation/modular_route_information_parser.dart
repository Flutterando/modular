import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modular_core/modular_core.dart';

import '../../../flutter_modular.dart';
import '../../domain/dtos/route_dto.dart';
import '../../domain/usecases/get_arguments.dart';
import '../../domain/usecases/get_route.dart';
import '../../domain/usecases/report_push.dart';
import '../../domain/usecases/set_arguments.dart';
import 'modular_book.dart';

class ModularRouteInformationParser
    extends RouteInformationParser<ModularBook> {
  final GetRoute getRoute;
  final GetArguments getArguments;
  final SetArguments setArguments;
  final ReportPush reportPush;

  bool _firstParse = false;

  ModularRouteInformationParser({
    required this.getRoute,
    required this.getArguments,
    required this.setArguments,
    required this.reportPush,
  });

  @override
  Future<ModularBook> parseRouteInformation(
      RouteInformation routeInformation) async {
    var path = '';
    if (!_firstParse) {
      if (routeInformation.location == null ||
          routeInformation.location == '/') {
        // ignore: invalid_use_of_visible_for_testing_member
        path = Modular.initialRoutePath;
      } else {
        path = routeInformation.location!;
      }

      _firstParse = true;
    } else {
      // ignore: invalid_use_of_visible_for_testing_member
      path = routeInformation.location ?? Modular.initialRoutePath;
    }

    return await selectBook(path);
  }

  @override
  RouteInformation restoreRouteInformation(ModularBook configuration) {
    return RouteInformation(location: configuration.uri.toString());
  }

  Future<ModularBook> selectBook(String path,
      {dynamic arguments, void Function(dynamic)? popCallback}) async {
    var route = await selectRoute(path, arguments: arguments);

    final modularArgs =
        getArguments().getOrElse((l) => ModularArguments.empty());

    if (popCallback != null) {
      route = route.copyWith(popCallback: popCallback);
    }

    late ModularBook book;

    if (route.parent.isEmpty) {
      reportPush(route);
      book = ModularBook(routes: [route]);
    } else {
      var parent = route.parent;
      book = ModularBook(routes: [route.copyWith(schema: parent)]);

      while (parent != '') {
        var child = await selectRoute(parent, arguments: arguments);
        parent = child.parent;
        child = child.copyWith(schema: parent);
        book.routes.insert(0, child);
      }

      setArguments(modularArgs);

      for (var booksRoute in book.routes) {
        reportPush(booksRoute);
      }
    }

    return book;
  }

  String _resolverPath(String relativePath) {
    return getArguments.call().fold((l) => relativePath, (r) {
      return r.uri.resolve(relativePath).toString();
    });
  }

  FutureOr<ParallelRoute> selectRoute(String path, {dynamic arguments}) async {
    if (path.isEmpty) {
      throw Exception('Route can not be empty');
    }

    path = _resolverPath(path);

    final params = RouteParmsDTO(url: path, arguments: arguments);
    final result = await getRoute.call(params);
    return await result.fold<FutureOr<ParallelRoute>>((modularError) async {
      if (path.endsWith('/')) {
        throw modularError;
      }
      final params = RouteParmsDTO(url: '$path/', arguments: arguments);
      final result = await getRoute.call(params);
      return await result.fold((l) => throw modularError, (route) {
        debugPrint('[MODULAR WARNING] - Please, use $path/ instead of $path.');
        return _routeSuccess(route);
      });
    }, (route) => _routeSuccess(route));
  }

  FutureOr<ParallelRoute> _routeSuccess(ModularRoute? route) async {
    final arguments = getArguments().getOrElse((l) => ModularArguments.empty());
    for (var middleware in route!.middlewares) {
      route = await middleware.pos(route!, arguments);
      if (route == null) {
        break;
      }
    }

    if (route is RedirectRoute) {
      route = await selectRoute(route.to, arguments: arguments);
    }

    if (route != null) {
      return route as ParallelRoute;
    }

    throw Exception('route can\'t null');
  }
}
