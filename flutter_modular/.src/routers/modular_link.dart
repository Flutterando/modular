import 'package:flutter/widgets.dart';
import '../delegates/modular_router_delegate.dart';
import '../interfaces/modular_navigator_interface.dart';

class ModularLink implements IModularNavigator {
  final ModularRouteDelegate delegate;

  ModularLink(this.delegate);

  @override
  bool canPop() => delegate.canPop();

  @override
  Future<T?> push<T extends Object>(Route<T> route) => delegate.push<T>(route);

  @override
  Future<bool> maybePop<T extends Object>([T? result]) =>
      delegate.maybePop<T>(result);

  @override
  void pop<T extends Object>([T? result]) => delegate.pop<T>(result);

  @override
  void popUntil(bool Function(Route<dynamic>) predicate) =>
      delegate.popUntil(predicate);

  @override
  String get modulePath => delegate.lastPage.modulePath ?? '/';
  @override
  String get path => delegate.lastPage.path ?? '/';

  @override
  void navigate(String path, {arguments}) => delegate.navigate(
        modulePath + path,
        arguments: arguments,
      );

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO? result,
      Object? arguments}) {
    return delegate.popAndPushNamed<T, TO>(
      modulePath + routeName,
      result: result,
      arguments: arguments,
    );
  }

  @override
  Future<T> pushNamed<T extends Object>(String routeName, {Object? arguments}) {
    return delegate.pushNamed<T>(
      modulePath + routeName,
      arguments: arguments,
    );
  }

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
      String newRouteName, bool Function(Route<dynamic>) predicate,
      {Object? arguments}) {
    return delegate.pushNamedAndRemoveUntil<T>(
      modulePath + newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  @override
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO? result,
      Object? arguments}) {
    return delegate.pushReplacementNamed<T, TO>(
      modulePath + routeName,
      result: result,
      arguments: arguments,
    );
  }
}
