import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/custom_transition.dart';
import '../models/modular_arguments.dart';
import 'child_module.dart';
import 'route_guard.dart';

typedef RouteBuilder<T> = MaterialPageRoute<T> Function(
    WidgetBuilder, RouteSettings);
typedef ModularChild = Widget Function(
    BuildContext context, ModularArguments? args);

abstract class ModularRoute<T> {
  ChildModule? get currentModule;

  ModularArguments? get args;

  List<ModularRoute> get children;

  final List<ModularRoute> routerOutlet = [];

  Uri? get uri;

  String? get path;

  ///
  /// Paramenter name: [routerName]
  ///
  /// Name for your route
  ///
  /// Type: String
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  String get routerName;

  ///
  /// Paramenter name: [child]
  ///
  /// The widget will be displayed
  ///
  /// Type: Widget
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///

  ModularChild? get child;

  ///
  /// Paramenter name: [module]
  ///
  /// The module will be loaded
  ///
  /// Type: ChildModule
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  ChildModule? get module;

  ///
  /// Paramenter name: [params]
  ///
  /// The parameters that can be transferred to another screen
  ///
  /// Type: Map<String, String>
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  Map<String, String>? get params;

  ///
  /// Paramenter name: [queryParams]
  ///
  /// The parameters that can be transferred to another screen
  ///
  /// Type: Map<String, String>
  ///
  /// For more example http://example.com/help?id=12&rate=22
  ///
  Map<String, String> get queryParams;

  ///
  /// Paramenter name: [queryParamsAll]
  ///
  /// The parameters that can be transferred to another screen
  ///
  /// Type: Map<String, String>
  ///
  /// For more example http://example.com/help?id=12&rate=22
  /// 
  Map<String, List<String>> get queryParamsAll;

  ///
  /// Paramenter name: [fragment]
  ///
  /// A url fragment that can be transferred to another screen mostly useful in flutter web
  ///
  /// Type: String
  ///
  /// For more example http://example.com/help#1223
  ///
  String get fragment;

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

  List<RouteGuard>? get guards;

  ///
  /// Paramenter name: [transition]
  ///
  /// Used to animate the transition from one screen to another
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  TransitionType get transition;

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
  ///
  CustomTransition? get customTransition;

  String? get modulePath;

  Duration get duration;

  RouteBuilder<T>? get routeGenerator;

  Map<
      TransitionType,
      PageRouteBuilder<T> Function(
          Widget Function(BuildContext, ModularArguments?) builder,
          ModularArguments? args,
          Duration transitionDuration,
          RouteSettings settings,
          )> get transitions;

  ModularRoute<T> copyWith({ModularChild? child,
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
    Uri uri,
    Duration? duration,
    Completer<T>? popRoute,
    ModularArguments? args,
    CustomTransition? customTransition});

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ModularRoute<T> &&
        o.modulePath == modulePath &&
        o.routerName == routerName &&
        o.module == module;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    return currentModule.hashCode ^ routerName.hashCode;
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
