import 'package:flutter/material.dart';

abstract class IModularNavigator implements Listenable {
  String get path;
  String get localPath;
  String get modulePath;

  /// Navigate to a new screen.
  ///
  /// ```
  /// Modular.to.push(MaterialPageRoute(builder: (context) => HomePage()),);
  /// ```
  Future<T?> push<T extends Object?>(Route<T> route);

  /// Pop the current route off the navigator and navigate to a route.
  ///
  /// ```
  /// Modular.to.popAndPushNamed('/home');
  /// ```
  /// You could give parameters
  /// ```
  /// Modular.to.popAndPushNamed('/home', arguments: 10);
  /// ```
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments, bool forRoot = false});

  /// Navigate to a route.
  ///
  /// ```
  /// Modular.to.pushNamed('/home/10');
  /// ```
  /// You could give parameters
  /// ```
  /// Modular.to.pushNamed('/home', arguments: 10);
  /// ```
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments, bool forRoot = false});

  /// Push the route with the given name onto the navigator that most tightly
  /// encloses the given context, and then remove all the previous routes until
  /// the predicate returns true.
  ///
  /// ```
  /// Modular.to.pushNamedAndRemoveUntil('/home/10', ModalRoute.withName('/'));
  /// ```
  /// You could give parameters
  /// ```
  /// Modular.to.pushNamedAndRemoveUntil('/home', ModalRoute.withName('/'), arguments: 10);
  /// ```
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(String newRouteName, bool Function(Route<dynamic>) predicate, {Object? arguments, bool forRoot = false});

  ///Replace the current route of the navigator that most tightly encloses the
  ///given context by pushing the route named routeName and then disposing the
  ///previous route once the new route has finished animating in.
  ///
  /// ```
  /// Modular.to.pushReplacementNamed('/home/10');
  /// ```
  /// You could give parameters
  /// ```
  /// Modular.to.pushReplacementNamed('/home', arguments: 10);
  /// ```
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments, bool forRoot = false});

  /// Removes the current Route from the stack of routes.
  ///
  /// ```
  /// Modular.to.pop();
  /// ```
  void pop<T extends Object>([T result]);

  /// The initial route cannot be popped off the navigator, which implies that
  /// this function returns true only if popping the navigator would not remove
  /// the initial route.
  ///
  /// ```
  /// Modular.to.canPop();
  /// ```
  bool canPop();

  ///Consults the current route's Route.willPop method, and acts accordingly,
  ///potentially popping the route as a result; returns whether the pop request
  ///should be considered handled.
  ///
  /// ```
  /// Modular.to.maybePop();
  /// ```
  Future<bool> maybePop<T extends Object>([T result]);

  ///Calls pop repeatedly on the navigator that most tightly encloses the given
  ///context until the predicate returns true.
  ///
  /// ```
  /// Modular.to.popUntil(ModalRoute.withName('/login'));
  /// ```
  void popUntil(bool Function(Route<dynamic>) predicate);

  void navigate(String path, {dynamic arguments, bool replaceAll = false});
}
