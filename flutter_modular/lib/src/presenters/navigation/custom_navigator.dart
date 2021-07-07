import 'package:flutter/widgets.dart';

import '../modular_base.dart';

class CustomNavigator extends Navigator {
  CustomNavigator({
    Key? key,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    List<Page<dynamic>> pages = const <Page<dynamic>>[],
    bool Function(Route<dynamic>, dynamic)? onPopPage,
  }) : super(key: key, pages: pages, onPopPage: onPopPage, observers: observers);

  @override
  _CustomNavigatorState createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends NavigatorState {
  @override
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return Modular.to.pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments}) {
    return Modular.to.popAndPushNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  @override
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(String newRouteName, predicate, {Object? arguments}) {
    return Modular.to.pushNamedAndRemoveUntil<T>(newRouteName, predicate, arguments: arguments);
  }

  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments}) {
    return Modular.to.pushReplacementNamed<T, TO>(routeName, result: result, arguments: arguments);
  }
}
