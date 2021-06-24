import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/interfaces/modular_route.dart';
import '../core/interfaces/module.dart';
import '../core/interfaces/route_guard.dart';
import '../core/models/custom_transition.dart';
import '../core/models/modular_arguments.dart';

import 'transitions/transitions.dart';

class ModularRouteEmpty extends ModularRouteImpl {
  ModularRouteEmpty() : super('fake', child: (_, __) => Container());
}

class ModularRouteImpl<T> extends ModularRoute<T> {
  @override
  final Module? currentModule;
  @override
  final ModularArguments args;
  @override
  final List<ModularRoute> children;
  @override
  final List<ModularRoute> routerOutlet;

  @override
  final Uri? uri;

  @override
  final String? modulePath;

  @override
  final String? guardedRoute;

  @override
  final String routerName;

  @override
  final ModularChild? child;

  @override
  final Module? module;

  @override
  final Map<String, String>? params;

  @override
  final List<RouteGuard>? guards;
  @override
  final TransitionType transition;

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
    Widget Function(BuildContext, ModularArguments) builder,
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
    this.children = const [],
    this.guardedRoute,
    this.args = const ModularArguments(),
    this.module,
    this.child,
    this.uri,
    this.guards,
    this.routerOutlet = const [],
    this.params,
    this.currentModule,
    this.transition = TransitionType.defaultTransition,
    this.routeGenerator,
    this.customTransition,
    this.duration = const Duration(milliseconds: 300),
    this.modulePath = '/',
  })  : assert(module == null || children.isEmpty, "can't have both module and nested routes(children)"),
        assert((transition == TransitionType.custom && customTransition != null) || transition != TransitionType.custom && customTransition == null),
        assert((module == null && child != null) || (module != null && child == null)),
        assert(routerName == '**' ? child != null : true);

  @override
  ModularRoute<T> copyWith(
      {ModularChild? child,
      String? routerName,
      Module? module,
      String? guardedRoute,
      List<ModularRoute>? children,
      List<ModularRoute>? routerOutlet,
      Module? currentModule,
      Map<String, String>? params,
      Uri? uri,
      List<RouteGuard>? guards,
      TransitionType? transition,
      RouteBuilder<T>? routeGenerator,
      String? modulePath,
      Duration? duration,
      Completer<T>? popRoute,
      ModularArguments? args,
      CustomTransition? customTransition}) {
    return ModularRouteImpl<T>(
      routerName ?? this.routerName,
      child: child ?? this.child,
      args: args ?? this.args,
      children: children ?? this.children,
      guardedRoute: guardedRoute ?? this.guardedRoute,
      module: module ?? this.module,
      routerOutlet: routerOutlet ?? this.routerOutlet,
      currentModule: currentModule ?? this.currentModule,
      params: params ?? this.params,
      uri: uri ?? this.uri,
      modulePath: modulePath ?? this.modulePath,
      guards: guards ?? this.guards,
      duration: duration ?? this.duration,
      routeGenerator: routeGenerator ?? this.routeGenerator,
      transition: transition ?? this.transition,
      customTransition: customTransition ?? this.customTransition,
    );
  }

  @override
  String? get path => uri?.toString() ?? '/';

  @override
  Map<String, List<String>> get queryParamsAll => uri?.queryParametersAll ?? {};

  @override
  Map<String, String> get queryParams => uri?.queryParameters ?? {};

  @override
  String get fragment => uri?.fragment ?? '';
}
