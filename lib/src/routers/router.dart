import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/interfaces/route_guard.dart';

class Router {
  final String routerName;
  final Widget Function(BuildContext context, ModularArguments args) child;
  final ChildModule module;
  Map<String, String> params;
  final List<RouteGuard> guards;
  final TransitionType transition;
  final CustomTransition customTransition;

  Router(
    this.routerName, {
    this.module,
    this.child,
    this.guards,
    this.params,
    this.transition = TransitionType.defaultTransition,
    this.customTransition,
  }) {
    assert(routerName != null);

    if (transition == null) throw ArgumentError('transition must not be null');
    if (module == null && child == null)
      throw ArgumentError('[module] or [child] must be provided');
    if (module != null && child != null)
      throw ArgumentError('You should provide only [module] or [child]');
  }

  Router copyWith(
      {Widget Function(BuildContext context, ModularArguments args) child,
      String routerName,
      ChildModule module,
      Map<String, String> params,
      List<RouteGuard> guards,
      TransitionType transition,
      CustomTransition customTransition}) {
    return Router(
      routerName ?? this.routerName,
      child: child ?? this.child,
      module: module ?? this.module,
      params: params ?? this.params,
      guards: guards ?? this.guards,
      transition: transition ?? this.transition,
      customTransition: customTransition ?? this.customTransition,
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
  custom,
}

class CustomTransition {
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)
      transitionBuilder;
  final Duration transitionDuration;

  CustomTransition(
      {@required this.transitionBuilder,
      this.transitionDuration = const Duration(milliseconds: 300)});
}
