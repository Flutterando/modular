import 'package:flutter/widgets.dart';

abstract class IModularNavigator {
  String get path;
  String get modulePath;
  NavigatorState get navigator;

  Future showDialog({
    Widget child,
    WidgetBuilder builder,
    bool barrierDismissible = true,
  });

  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO result,
      Object arguments});

  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments});

  Future<T> pushNamedAndRemoveUntil<T extends Object>(
      String newRouteName, bool Function(Route<dynamic>) predicate,
      {Object arguments});

  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO result,
      Object arguments});

  void pop<T extends Object>([T result]);

  bool canPop();

  Future<bool> maybePop<T extends Object>([T result]);

  void popUntil(bool Function(Route<dynamic>) predicate);
}
