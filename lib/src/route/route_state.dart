/// Immutable snapshot of the route the app is currently resolving.
///
/// Passed to every route `builder` as `(context, state)` — à la go_router.
/// Holds the full [uri], the matched path [params] (e.g. `:id`), exposes the
/// query string via [query], and carries any [arguments] passed to
/// `context.pushNamed(path, arguments: ...)`.
class RouteState {
  const RouteState({required this.uri, this.params = const {}, this.arguments});

  /// The full resolved URI (path + query).
  final Uri uri;

  /// Path parameters extracted from the matched route (e.g. `{'id': '42'}`).
  final Map<String, String> params;

  /// An arbitrary object passed at navigation time via
  /// `context.pushNamed(path, arguments: ...)`. NOT part of the URL, so it is
  /// `null` after a deep link / refresh — read it defensively.
  final Object? arguments;

  /// Query parameters (`?a=1&b=2`).
  Map<String, String> get query => uri.queryParameters;

  /// Convenience accessor for a path [params] entry.
  String? operator [](String key) => params[key];

  RouteState copyWith({
    Uri? uri,
    Map<String, String>? params,
    Object? arguments,
  }) {
    return RouteState(
      uri: uri ?? this.uri,
      params: params ?? this.params,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  String toString() =>
      'RouteState($uri, params: $params, arguments: $arguments)';
}
