import 'package:flutter/widgets.dart';
import '../../flutter_modular.dart';

class RouteLink extends IModularNavigator {
  final String path;
  final String modulePath;

  RouteLink({this.path, this.modulePath = "/"});

  RouteLink copy() {
    return RouteLink(path: path, modulePath: modulePath);
  }

  @override
  bool canPop() => Modular.navigator.canPop();

  @override
  Future<bool> maybePop<T extends Object>([T result]) {
    return Modular.navigator.maybePop(result);
  }

  @override
  void pop<T extends Object>([T result]) => Modular.navigator.pop(result);

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(String routeName, {TO result, Object arguments}) =>
      Modular.navigator.popAndPushNamed(_checkpath(routeName), result: result, arguments: arguments);

  @override
  void popUntil(bool Function(Route) predicate) => Modular.navigator.popUntil(predicate);

  @override
  Future<T> push<T extends Object>(Route<T> route) => Modular.navigator.push(route);

  @override
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) =>
      Modular.navigator.pushNamed(_checkpath(routeName), arguments: arguments);

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(String newRouteName, bool Function(Route) predicate,
          {Object arguments}) =>
      Modular.navigator.pushNamedAndRemoveUntil(_checkpath(newRouteName), predicate, arguments: arguments);
  @override
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(String routeName,
          {TO result, Object arguments}) =>
      Modular.navigator.pushReplacementNamed(_checkpath(routeName), result: result, arguments: arguments);

  @override
  Future<T> pushReplacement<T extends Object, TO extends Object>(Route<T> newRoute, {TO result}) =>
      Modular.navigator.pushReplacement(newRoute, result: result);

  @override
  Future showDialog({
    @deprecated Widget child,
    @required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) =>
      Modular.navigator.showDialog(builder: builder, child: child, barrierDismissible: barrierDismissible);

  String _checkpath(String routeName) {
    // Add a slash to the begin of route name if haven't
    routeName = routeName[0] == '/' ? routeName : '/$routeName';

    // Split main path to a list
    var modulePathList = modulePath.split('/');

    // While the route given by user starts with backward token string
    while (routeName.startsWith('/..')) {
      // Remove last item from main path
      modulePathList.removeLast();

      // remove this 3 chars from begin of user given route
      routeName = routeName.substring(3);
    }

    // Transform the list to string again
    final modulePathComp = modulePathList.reduce((value, element) => "$value/$element");

    var newPath = "$modulePathComp$routeName".replaceAll('//', '/');

    return newPath;
  }

  @override
  NavigatorState get navigator => Modular.to.navigator;
}
