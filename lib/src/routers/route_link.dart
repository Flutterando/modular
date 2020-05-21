import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RouteLink extends IModularNavigator {
  final String path;
  final String modulePath;

  RouteLink({this.path, this.modulePath = "/"});

  RouteLink copy() {
    return RouteLink(path: path, modulePath: modulePath);
  }

  @override
  bool canPop() => Modular.to.canPop();

  @override
  Future<bool> maybePop<T extends Object>([T result]) => Modular.to.maybePop(result);

  @override
  void pop<T extends Object>([T result]) => Modular.to.pop(result);

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(String routeName, {TO result, Object arguments}) =>
      Modular.to.popAndPushNamed(_checkpath(routeName), result: result, arguments: arguments);

  @override
  void popUntil(bool Function(Route) predicate) => Modular.to.popUntil(predicate);

  @override
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) =>
      Modular.to.pushNamed(_checkpath(routeName), arguments: arguments);

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(String newRouteName, bool Function(Route) predicate, {Object arguments}) =>
      Modular.to.pushNamedAndRemoveUntil(_checkpath(newRouteName), predicate, arguments: arguments);
  @override
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(String routeName, {TO result, Object arguments}) =>
      Modular.to.pushReplacementNamed(_checkpath(routeName), result: result, arguments: arguments);

  @override
  Future<T> pushReplacement<T extends Object, TO extends Object>(Route<T> newRoute, {TO result}) =>
      navigator.pushReplacement(newRoute, result: result);

  @override
  Future showDialog({
    @deprecated Widget child,
    @required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) =>
      Modular.to.showDialog(builder: builder, child: child, barrierDismissible: barrierDismissible);

  String _checkpath(String routeName) {
    routeName = routeName[0] == '/' ? routeName : '/$routeName';
    var newPath = "$modulePath$routeName".replaceAll('//', '/');
    return newPath;
  }

  @override
  NavigatorState get navigator => Modular.to.navigator;
}
