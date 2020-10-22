import 'package:flutter/widgets.dart';

import '../../flutter_modular.dart';

class RouteLink extends IModularNavigator {
  final String path;
  final String modulePath;
  final NavigatorState navigator;

  RouteLink(this.navigator, {this.path, this.modulePath = "/"});

  RouteLink copy() {
    return RouteLink(navigator, path: path, modulePath: modulePath);
  }

  @override
  bool canPop() => navigator.canPop();

  @override
  Future<bool> maybePop<T extends Object>([T result]) {
    return navigator.maybePop(result);
  }

  @override
  void pop<T extends Object>([T result]) => navigator.pop(result);

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
          String routeName,
          {TO result,
          Object arguments}) =>
      navigator.popAndPushNamed(_checkpath(routeName),
          result: result, arguments: arguments);

  @override
  void popUntil(bool Function(Route) predicate) =>
      navigator.popUntil(predicate);

  @override
  Future<T> push<T extends Object>(Route<T> route) => navigator.push(route);

  @override
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) =>
      navigator.pushNamed(_checkpath(routeName), arguments: arguments);

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
          String newRouteName, bool Function(Route) predicate,
          {Object arguments}) =>
      navigator.pushNamedAndRemoveUntil(_checkpath(newRouteName), predicate,
          arguments: arguments);
  @override
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
          String routeName,
          {TO result,
          Object arguments}) =>
      navigator.pushReplacementNamed(_checkpath(routeName),
          result: result, arguments: arguments);

  @override
  Future<T> pushReplacement<T extends Object, TO extends Object>(
          Route<T> newRoute,
          {TO result}) =>
      navigator.pushReplacement(newRoute, result: result);

  String _checkpath(String routeName) {
    routeName = routeName[0] == '/' ? routeName : '/$routeName';
    var newPath = "$modulePath$routeName".replaceAll('//', '/');
    return newPath;
  }
}
