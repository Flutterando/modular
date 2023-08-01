import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:modular_core/modular_core.dart';

import '../navigation/transitions/transitions.dart';

typedef ModularChild = Widget Function(BuildContext context);
typedef RouteBuilder<T> = Route<T> Function(WidgetBuilder, RouteSettings);

class ParallelRoute<T> extends ModularRoute {
  /// Whether the route should remain in memory when it is inactive.
  /// If this is true, then the route is maintained, so that any
  /// futures it is holding from the next route will properly resolve
  /// when the next route pops. If this is not necessary, this can
  /// be set to false to allow the framework to entirely discard
  /// the route's widget hierarchy when it is not visible.
  /// If this getter would ever start returning a different value,
  /// the changedInternalState should be invoked so that the change
  ///  can take effect.
  final bool maintainState;

  /// Widget Builder that will be called when prompted in navigation.
  final ModularChild? child;

  /// Transition performed when one page overlaps another.
  /// default is TransitionType.defaultTransition;
  final TransitionType? transition;

  /// Defines a custom transition.
  /// If the transition is TransitionType.custom, it becomes mandatory
  /// to add a CustomTransition() object.
  final CustomTransition? customTransition;

  /// define the Transition duration
  /// Default is 300 milliseconds
  final Duration? duration;

  /// Whether this page route is a full-screen dialog.
  /// Default is false;
  final bool isFullscreenDialog;

  @internal
  final void Function(dynamic)? popCallback;

  ParallelRoute({
    this.child,
    required String name,
    this.popCallback,
    this.maintainState = true,
    String parent = '',
    String schema = '',
    this.transition,
    this.customTransition,
    this.duration,
    this.isFullscreenDialog = false,
    List<ModularRoute> children = const [],
    List<Middleware> middlewares = const [],
    Module? module,
    Uri? uri,
    Map<Type, Module> innerModules = const {},
  }) : super(
          name,
          parent: parent,
          schema: schema,
          children: children,
          middlewares: middlewares,
          module: module,
          uri: uri ?? Uri.parse('/'),
          innerModules: innerModules,
        );

  factory ParallelRoute.child(
    String name, {
    required ModularChild child,
    CustomTransition? customTransition,
    List<ParallelRoute> children = const [],
    Duration? duration,
    TransitionType? transition,
    bool isFullscreenDialog = false,
    List<Middleware> middlewares = const [],
  }) {
    return ParallelRoute<T>(
      child: child,
      name: name,
      children: children,
      customTransition: customTransition,
      transition: transition,
      duration: duration,
      isFullscreenDialog: isFullscreenDialog,
      middlewares: middlewares,
    );
  }
  factory ParallelRoute.empty() {
    return ParallelRoute<T>(name: '');
  }

  factory ParallelRoute.module(
    String name, {
    required Module module,
    List<Middleware> middlewares = const [],
  }) {
    final route = ParallelRoute<T>(name: name, middlewares: middlewares);
    return route.addModule(name, module: module);
  }

  @override
  ParallelRoute<T> addModule(String name, {required Module module}) {
    final innerModules = {module.runtimeType: module};

    return copyWith(
      name: name,
      uri: Uri.parse(name),
      innerModules: innerModules,
      module: module,
    );
  }

  @override
  ModularRoute addParent(covariant ParallelRoute parent) {
    // ignore: invalid_use_of_visible_for_overriding_member
    final newRoute = super.addParent(parent) as ParallelRoute;
    return newRoute.copyWith(
      customTransition: customTransition ?? parent.customTransition,
      transition: transition ?? parent.transition,
      duration: duration ?? parent.duration,
    );
  }

  @override
  ParallelRoute<T> copyWith({
    ModularChild? child,
    Module? module,
    TransitionType? transition,
    CustomTransition? customTransition,
    Duration? duration,
    bool? isFullscreenDialog,
    String? name,
    String? schema,
    void Function(dynamic)? popCallback,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, Module>? innerModules,
  }) {
    return ParallelRoute<T>(
      child: child ?? this.child,
      transition: transition ?? this.transition,
      module: module ?? this.module,
      customTransition: customTransition ?? this.customTransition,
      duration: duration ?? this.duration,
      isFullscreenDialog: isFullscreenDialog ?? this.isFullscreenDialog,
      name: name ?? this.name,
      schema: schema ?? this.schema,
      popCallback: popCallback ?? this.popCallback,
      middlewares: middlewares ?? this.middlewares,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      uri: uri ?? this.uri,
      innerModules: innerModules ?? this.innerModules,
    );
  }

  final Map<
      TransitionType,
      PageRouteBuilder<T> Function(
        ModularChild builder,
        Duration transitionDuration,
        RouteSettings settings,
        bool maintainState,
      )> transitions = {
    TransitionType.fadeIn: fadeInTransition,
    TransitionType.rightToLeft: rightToLeft,
    TransitionType.leftToRight: leftToRight,
    TransitionType.upToDown: upToDown,
    TransitionType.downToUp: downToUp,
    TransitionType.scale: scale,
    TransitionType.rotate: rotate,
    TransitionType.size: size,
    TransitionType.rightToLeftWithFade: rightToLeftWithFade,
    TransitionType.leftToRightWithFade: leftToRightWithFade,
  };
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
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) transitionBuilder;
  Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
  )? pageBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final bool opaque;

  CustomTransition(
      {required this.transitionBuilder,
      this.transitionDuration = const Duration(milliseconds: 300),
      this.reverseTransitionDuration = const Duration(milliseconds: 300),
      this.opaque = true,
      this.pageBuilder});
}
