import 'package:flutter_modular/flutter_modular.dart';

extension RouteManageExt on RouteManager {
  void child(
    String name, {
    required ModularChild child,
    CustomTransition? customTransition,
    List<ParallelRoute> children = const [],
    Duration? duration,
    TransitionType? transition,
    bool maintainState = true,
    List<RouteGuard> guards = const [],
  }) {
    add(ChildRoute(
      name,
      child: child,
      children: children,
      customTransition: customTransition,
      duration: duration,
      transition: transition,
      maintainState: maintainState,
      guards: guards,
    ));
  }

  void redirect(
    String name, {
    required String to,
  }) {
    add(RedirectRoute(name, to: to));
  }

  void wildcard({
    required ModularChild child,
    TransitionType transition = TransitionType.defaultTransition,
    CustomTransition? customTransition,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    add(WildcardRoute(
      child: child,
      transition: transition,
      customTransition: customTransition,
      duration: duration,
    ));
  }

  void module(
    String name, {
    required Module module,
    TransitionType? transition,
    CustomTransition? customTransition,
    Duration? duration,
    List<RouteGuard> guards = const [],
  }) {
    add(ModuleRoute(
      name,
      module: module,
      customTransition: customTransition,
      duration: duration,
      transition: transition,
      guards: guards,
    ));
  }

  ModularArguments get args => Modular.args;
}
