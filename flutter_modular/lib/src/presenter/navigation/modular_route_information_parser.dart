import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_modular/src/domain/usecases/get_arguments.dart';
import 'package:flutter_modular/src/domain/usecases/get_route.dart';
import 'package:flutter_modular/src/domain/usecases/set_arguments.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:modular_core/modular_core.dart';

import 'modular_book.dart';

class ModularRouteInformationParser extends RouteInformationParser<ModularBook> {
  final GetRoute getRoute;
  final GetArguments getArguments;
  final SetArguments setArguments;

  ModularRouteInformationParser({required this.getRoute, required this.getArguments, required this.setArguments});

  @override
  Future<ModularBook> parseRouteInformation(RouteInformation routeInformation) async {
    // ignore: invalid_use_of_visible_for_testing_member
    final path = routeInformation.location ?? initialRouteDeclaratedInMaterialApp;

    return await selectBook(path);
  }

  @override
  RouteInformation restoreRouteInformation(ModularBook book) {
    return RouteInformation(location: book.uri.toString());
  }

  Future<ModularBook> selectBook(String path, {dynamic arguments, void Function(dynamic)? popCallback}) async {
    var route = await selectRoute(path, arguments: arguments);
    final modularArgs = getArguments().getOrElse((l) => ModularArguments.empty());
    if (popCallback != null) {
      route = route.copyWith(popCallback: popCallback);
    }

    if (route.parent.isEmpty) {
      return ModularBook(routes: [route]);
    }

    var parent = route.parent;
    final book = ModularBook(routes: [route.copyWith(schema: parent)]);

    while (parent != '') {
      var child = await selectRoute(parent, arguments: arguments);
      child = child.copyWith(schema: parent);
      book.routes.insert(0, child);
      parent = child.parent;
    }

    setArguments(modularArgs);
    return book;
  }

  FutureOr<ParallelRoute> selectRoute(String path, {dynamic arguments}) async {
    if (path.isEmpty) {
      throw Exception('Route can not be empty');
    }

    final params = RouteParmsDTO(url: path, arguments: arguments);
    final result = await getRoute.call(params);
    return await result.fold<FutureOr<ParallelRoute>>((l) => throw l, (route) => _routeSuccess(route));
  }

  FutureOr<ParallelRoute> _routeSuccess(ModularRoute? route) async {
    for (var middleware in route!.middlewares) {
      final args = getArguments().getOrElse((l) => ModularArguments.empty());
      route = await middleware.pos(route!, args);
      if (route == null) {
        break;
      }
    }

    if (route != null) {
      return route as ParallelRoute;
    }

    throw Exception('route can\'t null');
  }
}
