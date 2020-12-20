import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/interfaces/child_module.dart';
import '../core/interfaces/modular_route.dart';
import '../core/interfaces/route_guard.dart';
import '../core/models/custom_transition.dart';
import '../core/models/modular_arguments.dart';
import 'transitions/transitions.dart';



class ModularRouteImpl<T> extends ModularRoute<T> {
  @override
  final ChildModule? currentModule;
  @override
  final ModularArguments? args;
  @override
  final List<ModularRoute> children;
  @override
  final List<ModularRoute> routerOutlet;
  @override
  final String? path;
  @override
  final String? modulePath;

  ///
  /// Paramenter name: [routerName]
  ///
  /// Name for your route
  ///
  /// Type: String
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  @override
  final String routerName;

  ///
  /// Paramenter name: [child]
  ///
  /// The widget will be displayed
  ///
  /// Type: Widget
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  @override
  final ModularChild? child;

  ///
  /// Paramenter name: [module]
  ///
  /// The module will be loaded
  ///
  /// Type: ChildModule
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  @override
  final ChildModule? module;

  ///
  /// Paramenter name: [params]
  ///
  /// The parameters that can be transferred to another screen
  ///
  /// Type: Map<String, String>
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  @override
  final Map<String, String>? params;

  ///
  /// Paramenter name: [guards]
  ///
  /// Route guards are middleware-like objects
  ///
  /// that allow you to control the access of a given route from other route.
  ///
  /// You can implement a route guard by making a class that implements RouteGuard.
  ///
  /// Type: List<RouteGuard>
  ///
  /// Example:
  /// ```dart
  ///class MyGuard implements RouteGuard {
  ///  @override
  ///  Future<bool> canActivate(String url, ModularRoute router) {
  ///    if (url != '/admin'){
  ///      // Return `true` to allow access
  ///      return true;
  ///    } else {
  ///      // Return `false` to disallow access
  ///      return false
  ///    }
  ///  }
  ///}
  /// ```
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  @override
  final List<RouteGuard>? guards;

  ///
  /// Paramenter name: [transition]
  ///
  /// Used to animate the transition from one screen to another
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  @override
  final TransitionType transition;

  ///
  /// Paramenter name: [customTransiton]
  ///
  /// PS: For [customTransition] to work,
  ///
  /// you must set the [transition] parameter for
  /// ```dart
  /// transition.custom,
  /// ```
  ///
  /// Example: Using just First Animation
  /// ```dart
  /// customTransition: CustomTransition(
  ///   transitionBuilder: (context, animation, secondaryAnimation, child) {
  ///     return SlideTransition(
  ///         transformHitTests: false,
  ///         position: Tween<Offset>(
  ///           begin: const Offset(0.0, 1.0),
  ///           end: Offset.zero,
  ///         ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  ///         child: child);
  ///   },
  /// ),
  /// ```

  /// Example: Using just secondaryAnimation
  /// ```dart
  /// customTransition: CustomTransition(
  /// transitionBuilder: (context, animation, secondaryAnimation, child) {
  ///   return SlideTransition(
  ///     transformHitTests: false,
  ///     position: Tween<Offset>(
  ///       begin: const Offset(0.0, 1.0),
  ///       end: Offset.zero,
  ///     ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  ///     child: SlideTransition(
  ///       transformHitTests: false,
  ///       position: Tween<Offset>(
  ///         begin: Offset.zero,
  ///         end: const Offset(0.0, -1.0),
  ///       ).chain(CurveTween(curve: Curves.ease)).animate(secondaryAnimation),
  ///       child: child,
  ///     ),
  ///   );
  ///   },
  /// ),
  /// ```
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  @override
  final CustomTransition? customTransition;

  @override
  final Duration duration;

  @override
  final RouteBuilder<T>? routeGenerator;

  @override
  final Map<
      TransitionType,
      PageRouteBuilder<T> Function(
    Widget Function(BuildContext, ModularArguments?) builder,
    ModularArguments? args,
    Duration transitionDuration,
    RouteSettings settings,
  )> transitions = {
    TransitionType.fadeIn: fadeInTransition,
    TransitionType.noTransition: noTransition,
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

  ModularRouteImpl(
    this.routerName, {
    this.path = '/',
    this.children = const [],
    this.args = const ModularArguments(),
    this.module,
    this.child,
    this.guards,
    this.routerOutlet = const [],
    this.params,
    this.currentModule,
    this.transition = TransitionType.defaultTransition,
    this.routeGenerator,
    this.customTransition,
    this.duration = const Duration(milliseconds: 300),
    this.modulePath = '/',
  })  : assert(module == null ? true : children.isEmpty,
            'Módulo não pode conter rotas aninhadas (children)'),
        assert((transition == TransitionType.custom &&
                customTransition != null) ||
            transition != TransitionType.custom && customTransition == null),
        assert((module == null && child != null) ||
            (module != null && child == null)),
        assert(routerName == '**' ? child != null : true);

  @override
  ModularRoute<T> copyWith(
      {ModularChild? child,
      String? routerName,
      ChildModule? module,
      List<ModularRoute>? children,
      List<ModularRoute>? routerOutlet,
      ChildModule? currentModule,
      Map<String, String>? params,
      List<RouteGuard>? guards,
      TransitionType? transition,
      RouteBuilder<T>? routeGenerator,
      String? modulePath,
      String? path,
      Duration? duration,
      Completer<T>? popRoute,
      ModularArguments? args,
      CustomTransition? customTransition}) {
    return ModularRouteImpl<T>(
      routerName ?? this.routerName,
      child: child ?? this.child,
      args: args ?? this.args,
      children: children ?? this.children,
      module: module ?? this.module,
      routerOutlet: routerOutlet ?? this.routerOutlet,
      currentModule: currentModule ?? this.currentModule,
      params: params ?? this.params,
      modulePath: modulePath ?? this.modulePath,
      path: path ?? this.path,
      guards: guards ?? this.guards,
      duration: duration ?? this.duration,
      routeGenerator: routeGenerator ?? this.routeGenerator,
      transition: transition ?? this.transition,
      customTransition: customTransition ?? this.customTransition,
    );
  }
}
