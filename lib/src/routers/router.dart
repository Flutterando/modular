import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/interfaces/route_guard.dart';

class Router {
  final String routerName;
  final Widget Function(BuildContext context, ModularArguments args) child;
  final ChildModule module;
  Map<String, dynamic> params;
  final List<RouteGuard> guards;
  final TransitionType transition;

  Router(
    this.routerName, {
    this.module,
    this.child,
    this.guards,
    this.params,
    this.transition = TransitionType.defaultTransition,
  }) {
    assert(routerName != null);

    if(transition == null)
      throw ArgumentError('transaction must not be null');
    if(module == null && child == null)
       throw ArgumentError('[module] or [child] must be provided');
    if(module != null && child != null)
      throw ArgumentError('You should provide only [module] or [child]');
  }

  copyWith({
    Widget Function(BuildContext context, ModularArguments args) child,
    String routerName,
    ChildModule module,
    Map<String, dynamic> params,
    List<RouteGuard> guards,
    TransitionType transition,
  }) {
    return Router(
      routerName,
      child: child ?? this.child,
      module: module ?? this.module,
      params: params ?? this.params,
      guards: guards ?? this.guards,
      transition: transition ?? this.transition,
    );
  }
}

enum TransitionType {
  defaultTransition,
  fadeIn,
  noTransition,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
}
