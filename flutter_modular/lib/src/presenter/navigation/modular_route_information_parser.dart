// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/src/domain/errors/errors.dart';
import 'package:result_dart/result_dart.dart';

import '../../../flutter_modular.dart';
import '../../domain/dtos/route_dto.dart';
import '../../domain/usecases/get_arguments.dart';
import '../../domain/usecases/get_route.dart';
import '../../domain/usecases/report_push.dart';
import '../../domain/usecases/set_arguments.dart';
import '../../infra/services/url_service/url_service.dart';
import 'modular_book.dart';

class ModularRouteInformationParser
    extends RouteInformationParser<ModularBook> {
  final GetRoute getRoute;
  final GetArguments getArguments;
  final SetArguments setArguments;
  final ReportPush reportPush;
  final UrlService urlService;

  ModularRouteInformationParser({
    required this.getRoute,
    required this.getArguments,
    required this.setArguments,
    required this.reportPush,
    required this.urlService,
  });

  @override
  Future<ModularBook> parseRouteInformation(
      RouteInformation routeInformation) async {
    var path = '';

    // 3.10 wrapper
    final location = [null].contains(routeInformation.uri.path)
        ? '/'
        : routeInformation.uri.path;
    if (location == '/') {
      // ignore: invalid_use_of_visible_for_testing_member
      path = urlService.getPath() ?? Modular.initialRoutePath;
    } else {
      // 3.10 wrapper
      path = location;
    }

    return selectBook(path);
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
        if (parent == route.parent) {
          parent = '';
          continue;
        }
        child = child.copyWith(schema: parent);
        book.routes.insert(0, child);
      }

      setArguments(modularArgs);

      for (final booksRoute in book.routes) {
        reportPush(booksRoute);
      }
    }

    return book;
  }

  String _resolverPath(String relativePath) {
    return getArguments //
        .call()
        .map((r) => r.uri.resolve(relativePath))
        .map((s) => s.toString())
        .getOrDefault(relativePath);
  }

  FutureOr<ParallelRoute> selectRoute(String path, {dynamic arguments}) async {
    if (path.isEmpty) {
      throw Exception('Route can not be empty');
    }

    path = _resolverPath(path);

    final params = RouteParmsDTO(url: path, arguments: arguments);

    final fistTrying = getRoute.call(params).flatMap<ModularRoute>((success) {
      if (success.name == '/**') {
        return const Failure(RouteNotFoundException(
            'Wildcard is not available for the first time'));
      }
      return Success(success);
    });

    return fistTrying.map(_routeSuccess).recover((modularError) {
      final params = RouteParmsDTO(url: '$path/', arguments: arguments);
      return getRoute
          .call(params) //
          .map(_routeSuccess)
          .map((success) {
        debugPrint('[MODULAR WARNING] - Please, use $path/ instead of $path.');

        return success;
      });
    }).getOrThrow();
  }

  FutureOr<ParallelRoute> _routeSuccess(ModularRoute? route) async {
    final modularArguments =
        getArguments().getOrElse((l) => ModularArguments.empty());
    for (final middleware in route!.middlewares) {
      route = await middleware.pos(route!, modularArguments);
      if (route == null) {
        break;
      }
    }

    if (route is RedirectRoute) {
      route = await selectRoute(route.to, arguments: modularArguments.data);
    }

    if (route != null) {
      return route as ParallelRoute;
    }

    throw Exception("route can't null");
  }
}
