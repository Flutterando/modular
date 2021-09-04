import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/domain/usecases/report_pop.dart';
import 'package:flutter_modular/src/presenter/models/modular_args.dart';
import 'package:flutter_modular/src/presenter/models/modular_navigator.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:modular_core/modular_core.dart';

import 'custom_navigator.dart';
import 'modular_book.dart';
import 'modular_page.dart';
import 'modular_route_information_parser.dart';

class ModularRouterDelegate extends RouterDelegate<ModularBook>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ModularBook>
    implements
        IModularNavigator {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final ModularRouteInformationParser parser;
  final ReportPop reportPop;
  List<NavigatorObserver> observers = [];

  ModularRouterDelegate({required this.parser, required this.navigatorKey, required this.reportPop});

  @override
  ModularBook? currentConfiguration;

  @override
  Widget build(BuildContext context) {
    final pages = currentConfiguration?.chapters().toList() ?? [];
    if (pages.isEmpty) {
      return Material();
    }

    return CustomNavigator(
      key: navigatorKey,
      modularBase: Modular,
      pages: pages,
      observers: observers,
      onPopPage: onPopPage,
    );
  }

  @override
  void setObserver(List<NavigatorObserver> navigatorObservers) {
    observers = navigatorObservers;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(ModularBook book) async {
    currentConfiguration = book;
    notifyListeners();
  }

  var _lastClick = DateTime.now();

  @override
  Future<void> navigate(String routeName, {arguments}) async {
    final currentTime = DateTime.now();
    if (currentTime.difference(_lastClick).inMilliseconds < 500) {
      return;
    }
    if (routeName == path) {
      return;
    }
    _lastClick = currentTime;
    final book = await parser.selectBook(routeName, arguments: arguments);
    return await setNewRoutePath(book);
  }

  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result) || route.isFirst) {
      return false;
    }

    final page = route.settings as ModularPage;
    final parallel = page.route;
    parallel.popCallback?.call(result);
    currentConfiguration?.routes.remove(parallel);
    reportPop.call(parallel);
    notifyListeners();

    return true;
  }

  @override
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments, bool forRoot = false}) async {
    final popComplete = Completer();
    var book = await parser.selectBook(routeName, arguments: arguments, popCallback: popComplete.complete);
    if (forRoot) {
      book = currentConfiguration!.copyWith(routes: [...currentConfiguration!.routes, book.routes.last.copyWith(schema: '')]);
      await setNewRoutePath(book);
    } else {
      final list = [...currentConfiguration!.routes];

      for (var route in book.routes.reversed) {
        if (list.firstWhere((element) => element.uri.toString() == route.uri.toString(), orElse: () => ParallelRoute.empty()).name == '') {
          list.add(route);
        }
      }
      await setNewRoutePath(book.copyWith(routes: list));
    }

    return await popComplete.future;
  }

  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments, bool forRoot = false}) async {
    final popComplete = Completer();
    var book = await parser.selectBook(routeName, arguments: arguments, popCallback: popComplete.complete);
    final currentRoutes = [...currentConfiguration!.routes];
    if (forRoot) {
      currentRoutes.removeWhere((element) => element.schema != '');
      currentRoutes.removeLast();
      book = currentConfiguration!.copyWith(routes: [...currentRoutes, book.routes.first.copyWith(schema: '')]);
      await setNewRoutePath(book);
    } else {
      final list = [...currentConfiguration!.routes]..removeLast();

      for (var route in book.routes.reversed) {
        if (list.firstWhere((element) => element.uri.toString() == route.uri.toString(), orElse: () => ParallelRoute.empty()).name == '') {
          list.add(route);
        }
      }
      await setNewRoutePath(book.copyWith(routes: list));
    }

    return await popComplete.future;
  }

  @override
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments, bool forRoot = false}) {
    pop(result);
    return pushNamed(routeName, arguments: arguments);
  }

  @override
  bool canPop() => navigatorKey.currentState?.canPop() ?? false;

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) => navigatorKey.currentState?.maybePop(result) ?? Future.value(false);

  @override
  void pop<T extends Object?>([T? result]) => navigatorKey.currentState?.pop(result);

  @override
  void popUntil(bool Function(Route) predicate) {
    var isFoundedPages = currentConfiguration?.routes.where((route) {
      return predicate(CustomModalRoute(ModularPage(route: route, args: ModularArguments.empty(), flags: ModularFlags())));
    });

    isFoundedPages ??= [];
    if (isFoundedPages.isEmpty) {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      navigatorKey.currentState?.popUntil(predicate);
    }
  }

  @override
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(String newRouteName, bool Function(Route) predicate, {Object? arguments, bool forRoot = false}) {
    popUntil(predicate);
    return pushNamed<T>(newRouteName, arguments: arguments, forRoot: forRoot);
  }

  @override
  String get path => currentConfiguration?.uri.toString() ?? '/';

  @override
  Future<T?> push<T extends Object?>(Route<T> route) async {
    return await navigatorKey.currentState?.push<T>(route);
  }
}

class CustomModalRoute extends ModalRoute {
  CustomModalRoute(RouteSettings settings) : super(settings: settings);

  @override
  Color? get barrierColor => throw UnimplementedError();

  @override
  bool get barrierDismissible => throw UnimplementedError();

  @override
  String? get barrierLabel => throw UnimplementedError();

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    throw UnimplementedError();
  }

  @override
  bool get maintainState => throw UnimplementedError();

  @override
  bool get opaque => throw UnimplementedError();

  @override
  Duration get transitionDuration => throw UnimplementedError();
}
