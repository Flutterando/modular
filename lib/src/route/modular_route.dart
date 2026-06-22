import 'package:flutter/widgets.dart';

import '../navigation/transition.dart';
import '../state/scoped.dart';
import 'route_state.dart';

/// Builds the widget for a route, receiving the current [RouteState].
typedef ModularWidgetBuilder =
    Widget Function(BuildContext context, RouteState state);

/// A route guard: returns a redirect path to send the user elsewhere, or
/// `null` to allow navigation.
typedef ModularGuard = String? Function(RouteState state);

/// A single declared route: a RELATIVE path pattern, a builder, optional
/// page-scoped state ([provide]), nested [children], [guards] and a
/// [transition].
class ModularRoute {
  const ModularRoute(
    this.path,
    this.builder, {
    this.provide,
    this.children = const [],
    this.guards = const [],
    this.transition = TransitionType.material,
    this.ownerTags = const [],
  });

  final String path;
  final ModularWidgetBuilder builder;
  final void Function(Scoped scoped)? provide;
  final List<ModularRoute> children;
  final List<ModularGuard> guards;
  final TransitionType transition;

  /// Tags of the feature modules (mounted via `module(at:)`) that own this
  /// route. When the LAST active route of a tag leaves the stack, that module's
  /// binds are disposed. Empty for root-owned routes.
  final List<String> ownerTags;
}

/// One matched level of a route chain: the route + its captured path params.
class RouteLevel {
  const RouteLevel(this.route, this.params);

  final ModularRoute route;
  final Map<String, String> params;
}

/// The declared route tree + the hierarchical matcher.
class RouteCollection {
  final List<ModularRoute> _routes = [];

  List<ModularRoute> get routes => List.unmodifiable(_routes);

  void add(ModularRoute route) => _routes.add(route);

  /// Matches [uri] to a chain of routes (root → leaf) with params, or `null`.
  List<RouteLevel>? match(Uri uri) => _matchChain(_routes, _segments(uri.path));
}

List<RouteLevel>? _matchChain(
  List<ModularRoute> routes,
  List<String> segments,
) {
  for (final route in routes) {
    final consumed = _tryConsume(route.path, segments);
    if (consumed == null) continue;

    final remaining = segments.sublist(consumed.$1);
    final level = RouteLevel(route, consumed.$2);

    if (remaining.isEmpty) {
      if (route.children.isEmpty) return [level];
      final index = _matchChain(route.children, const []);
      return index == null ? [level] : [level, ...index];
    }

    final childChain = _matchChain(route.children, remaining);
    if (childChain != null) return [level, ...childChain];
  }
  return null;
}

/// Matches a pattern (`/product/:id`) against the FRONT of [segments],
/// returning (segments consumed, captured params) or `null`.
(int, Map<String, String>)? _tryConsume(String pattern, List<String> segments) {
  final patternSegments = _segments(pattern);
  if (patternSegments.length > segments.length) return null;

  final params = <String, String>{};
  for (var i = 0; i < patternSegments.length; i++) {
    final seg = patternSegments[i];
    if (seg.startsWith(':')) {
      params[seg.substring(1)] = segments[i];
    } else if (seg != segments[i]) {
      return null;
    }
  }
  return (patternSegments.length, params);
}

List<String> _segments(String path) =>
    path.split('/').where((s) => s.isNotEmpty).toList();
