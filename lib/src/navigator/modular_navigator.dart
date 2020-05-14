import 'package:flutter/material.dart';

import '../../flutter_modular.dart';
import 'modular_navigator_interface.dart';

class ModularNavigator implements IModularNavigator {
  final NavigatorState navigator;

  ModularNavigator(this.navigator);

  @override
  Future showDialog({
    @deprecated Widget child,
    @required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return navigator.push(DialogRoute(
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        final pageChild = child ?? Builder(builder: builder);
        return SafeArea(
          child: Builder(builder: (context) {
            return pageChild;
          }),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierLabel:
          "barier-label", //MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: _buildMaterialDialogTransitions,
    ));
  }

  Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }

  @override
  bool canPop() => navigator.canPop();

  @override
  Future<bool> maybePop<T extends Object>([T result]) =>
      navigator.maybePop(result);

  @override
  void pop<T extends Object>([T result]) => navigator.pop(result);

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
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) =>
      navigator.pushNamed(routeName, arguments: arguments);

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

class DialogRoute<T> extends PopupRoute<T> {
  DialogRoute({
    @required RoutePageBuilder pageBuilder,
    bool barrierDismissible = true,
    String barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder transitionBuilder,
    RouteSettings settings,
  })  : assert(barrierDismissible != null),
        _pageBuilder = pageBuilder,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _barrierColor = barrierColor,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder,
        super(settings: settings);

  final RoutePageBuilder _pageBuilder;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  final String _barrierLabel;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final RouteTransitionsBuilder _transitionBuilder;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Semantics(
      child: _pageBuilder(context, animation, secondaryAnimation),
      scopesRoute: true,
      explicitChildNodes: true,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (_transitionBuilder == null) {
      return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child);
    } // Some default transition
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}
