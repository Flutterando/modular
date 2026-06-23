import 'package:flutter/material.dart';

/// The contract a route transition implements: given a key and the route's
/// child, it produces the [Page] that wraps it in the navigator stack.
///
/// Three ways to supply one to `route(transition:)` (or `ModularApp`'s
/// app-wide default):
///  - the [TransitionType] presets ([TransitionType.material], `.fade`,
///    `.none`) — each value IS a [PageTransition];
///  - [CustomTransition] — the convenience for "I just want a different
///    animation"; Modular still owns the [Page];
///  - implement [PageTransition] yourself for FULL control of the [Page]
///    (a `CupertinoPage` with interactive swipe-back, a `fullscreenDialog`,
///    a custom barrier, shared-axis from the `animations` package, …).
abstract class PageTransition {
  const PageTransition();

  /// Builds the [Page] for [child], stamped with [key] so the Navigator can
  /// track it across rebuilds.
  Page<void> buildPage(LocalKey key, Widget child);
}

/// Built-in transition presets. Each value is itself a [PageTransition], so
/// `transition: TransitionType.fade` keeps working while the field accepts any
/// custom [PageTransition].
enum TransitionType implements PageTransition {
  material,
  fade,
  none;

  @override
  Page<void> buildPage(LocalKey key, Widget child) {
    switch (this) {
      case TransitionType.material:
        return MaterialPage<void>(key: key, child: child);
      case TransitionType.fade:
        return _TransitionPage(
          key: key,
          child: child,
          transitionsBuilder: (context, animation, secondary, c) =>
              FadeTransition(opacity: animation, child: c),
        );
      case TransitionType.none:
        return _TransitionPage(
          key: key,
          child: child,
          duration: Duration.zero,
          transitionsBuilder: (context, animation, secondary, c) => c,
        );
    }
  }
}

/// A [PageTransition] you build inline by supplying just the animation.
///
/// Modular owns the [Page]/[PageRoute]; you provide [transitionsBuilder] (the
/// same signature as `PageRouteBuilder.transitionsBuilder`) and optionally tune
/// [duration], [reverseDuration] and the route flags. For control over the
/// [Page] itself, implement [PageTransition] directly instead.
///
/// ```dart
/// c.route('/details/:id',
///   transition: CustomTransition(
///     duration: const Duration(milliseconds: 250),
///     transitionsBuilder: (ctx, anim, sec, child) => SlideTransition(
///       position: anim.drive(
///         Tween(begin: const Offset(1, 0), end: Offset.zero),
///       ),
///       child: child,
///     ),
///   ),
///   child: (ctx, state) => DetailsPage(id: state.params['id']!));
/// ```
class CustomTransition extends PageTransition {
  const CustomTransition({
    required this.transitionsBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.opaque = true,
    this.barrierColor,
    this.barrierDismissible = false,
    this.fullscreenDialog = false,
  });

  /// Builds the animated wrapper around the page's content — receives the
  /// primary and secondary route animations.
  final RouteTransitionsBuilder transitionsBuilder;

  /// Forward (and, unless [reverseDuration] is set, reverse) transition length.
  final Duration duration;

  /// Reverse transition length; falls back to [duration] when omitted.
  final Duration? reverseDuration;

  /// Whether the route obscures the one below (`false` keeps it visible, e.g.
  /// for a translucent overlay).
  final bool opaque;

  /// Barrier color painted behind a non-[opaque] route.
  final Color? barrierColor;

  /// Whether tapping the barrier pops the route.
  final bool barrierDismissible;

  /// Whether to animate as a fullscreen dialog (affects the default Material
  /// transition and the close affordance).
  final bool fullscreenDialog;

  @override
  Page<void> buildPage(LocalKey key, Widget child) => _TransitionPage(
    key: key,
    child: child,
    transitionsBuilder: transitionsBuilder,
    duration: duration,
    reverseDuration: reverseDuration,
    opaque: opaque,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    fullscreenDialog: fullscreenDialog,
  );
}

/// The [Page] backing [TransitionType.fade]/`.none` and [CustomTransition]:
/// a [PageRouteBuilder] whose content is [child] and whose animation is
/// [transitionsBuilder].
class _TransitionPage extends Page<void> {
  const _TransitionPage({
    required super.key,
    required this.child,
    required this.transitionsBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.opaque = true,
    this.barrierColor,
    this.barrierDismissible = false,
    this.fullscreenDialog = false,
  });

  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;
  final Duration duration;
  final Duration? reverseDuration;
  final bool opaque;
  final Color? barrierColor;
  final bool barrierDismissible;
  final bool fullscreenDialog;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration ?? duration,
      opaque: opaque,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (context, animation, secondary) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }
}
