import 'package:flutter/material.dart';
import '../../flutter_modular.dart';
import '../delegates/modular_router_delegate.dart';
import '../interfaces/modular_navigator_interface.dart';

class ModularNavigator implements IModularNavigator {
  final ModularRouterDelegate routerDelegate;

  ModularNavigator(this.routerDelegate);

  NavigatorState get navigator => routerDelegate.navigatorKey.currentState;

  @override
  bool canPop() => navigator.canPop();

  @override
  Future<bool> maybePop<T extends Object>([T result]) =>
      navigator.maybePop(result);

  @override
  void pop<T extends Object>([T result]) => navigator.pop(result);

  @override
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) =>
      routerDelegate.pushNamed<T>(routeName, arguments: arguments);

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
          String routeName,
          {TO result,
          Object arguments}) =>
      navigator.popAndPushNamed(
        routeName,
        result: result,
        arguments: arguments,
      );

  @override
  void popUntil(bool Function(Route) predicate) =>
      navigator.popUntil(predicate);

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
          String newRouteName, bool Function(Route) predicate,
          {Object arguments}) =>
      navigator.pushNamedAndRemoveUntil(newRouteName, predicate,
          arguments: arguments);

  @override
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
          String routeName,
          {TO result,
          Object arguments}) =>
      navigator.pushReplacementNamed(routeName,
          result: result, arguments: arguments);

  @override
  String get modulePath => Modular.link.modulePath;

  @override
  String get path => Modular.link.path;
}
