import 'package:flutter/material.dart';

/// Page transition for a route.
enum TransitionType { material, fade, none }

/// Builds the [Page] for [child] with the requested [type].
Page<void> buildTransitionPage(
  TransitionType type,
  LocalKey key,
  Widget child,
) {
  switch (type) {
    case TransitionType.material:
      return MaterialPage<void>(key: key, child: child);
    case TransitionType.fade:
      return _TransitionPage(
        key: key,
        child: child,
        transitions: (animation, c) =>
            FadeTransition(opacity: animation, child: c),
      );
    case TransitionType.none:
      return _TransitionPage(
        key: key,
        child: child,
        duration: Duration.zero,
        transitions: (animation, c) => c,
      );
  }
}

class _TransitionPage extends Page<void> {
  const _TransitionPage({
    required super.key,
    required this.child,
    required this.transitions,
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Widget Function(Animation<double> animation, Widget child) transitions;
  final Duration duration;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondary) => child,
      transitionsBuilder: (context, animation, secondary, c) =>
          transitions(animation, c),
    );
  }
}
