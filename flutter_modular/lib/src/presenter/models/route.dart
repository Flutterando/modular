import 'package:flutter/material.dart';
import 'package:flutter_modular/src/presenter/navigation/transitions/transitions.dart';
import 'package:meta/meta.dart';
import 'package:modular_core/modular_core.dart';

import 'module.dart';

typedef ModularChild = Widget Function(
    BuildContext context, ModularArguments args);
typedef RouteBuilder<T> = Route<T> Function(WidgetBuilder, RouteSettings);

class ParallelRoute<T> extends ModularRouteImpl {
  /// Widget Builder that will be called when prompted in navigation.
  final ModularChild? child;

  /// Transition performed when one page overlaps another.
  /// default is TransitionType.defaultTransition;
  final TransitionType? transition;

  /// Defines a custom transition.
  /// If the transition is TransitionType.custom, it becomes mandatory to add a CustomTransition() object.
  final CustomTransition? customTransition;

  /// define the Transition duration
  /// Default is 300 milliseconds
  final Duration? duration;

  final RouteBuilder<T>? routeGenerator;

  @internal
  final void Function(dynamic)? popCallback;

  ParallelRoute({
    this.child,
    required String name,
    this.popCallback,
    String parent = '',
    String schema = '',
    this.transition,
    this.routeGenerator,
    this.customTransition,
    this.duration,
    List<ModularRoute> children = const [],
    List<Middleware> middlewares = const [],
    RouteContext? context,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext> bindContextEntries = const {},
  }) : super(
          name: name,
          parent: parent,
          schema: schema,
          children: children,
          middlewares: middlewares,
          context: context,
          uri: uri ?? Uri.parse('/'),
          bindContextEntries: bindContextEntries,
        );

  factory ParallelRoute.child(
    String name, {
    required ModularChild child,
    CustomTransition? customTransition,
    List<ParallelRoute> children = const [],
    Duration? duration,
    TransitionType? transition,
    List<Middleware> middlewares = const [],
  }) {
    return ParallelRoute<T>(
      child: child,
      name: name,
      children: children,
      customTransition: customTransition,
      transition: transition,
      duration: duration,
      middlewares: middlewares,
    );
  }
  factory ParallelRoute.empty() {
    return ParallelRoute<T>(name: '');
  }

  factory ParallelRoute.module(String name,
      {required Module module, List<Middleware> middlewares = const []}) {
    final route = ParallelRoute<T>(name: name, middlewares: middlewares);
    return route.addModule(name, module: module);
  }

  @override
  ParallelRoute<T> addModule(String name, {required RouteContext module}) {
    final bindContextEntries = {module.runtimeType: module};

    return copyWith(
      name: name,
      uri: Uri.parse(name),
      bindContextEntries: bindContextEntries,
      context: module,
    );
  }

  @override
  ParallelRoute<T> copyWith({
    ModularChild? child,
    RouteContext? context,
    TransitionType? transition,
    CustomTransition? customTransition,
    Duration? duration,
    String? name,
    String? schema,
    void Function(dynamic)? popCallback,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
    RouteBuilder<T>? routeGenerator,
  }) {
    return ParallelRoute<T>(
      child: child ?? this.child,
      transition: transition ?? this.transition,
      context: context ?? this.context,
      customTransition: customTransition ?? this.customTransition,
      duration: duration ?? this.duration,
      name: name ?? this.name,
      schema: schema ?? this.schema,
      popCallback: popCallback ?? this.popCallback,
      middlewares: middlewares ?? this.middlewares,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      uri: uri ?? this.uri,
      bindContextEntries: bindContextEntries ?? this.bindContextEntries,
      routeGenerator: routeGenerator ?? this.routeGenerator,
    );
  }

  final Map<
      TransitionType,
      PageRouteBuilder<T> Function(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings,
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
          BuildContext, Animation<double>, Animation<double>, Widget)
      transitionBuilder;
  final Duration transitionDuration;

  CustomTransition(
      {required this.transitionBuilder,
      this.transitionDuration = const Duration(milliseconds: 300)});
}
