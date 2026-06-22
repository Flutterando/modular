import 'package:flutter/widgets.dart';

import '../route/route_state.dart';

/// Translates between the platform's [RouteInformation] (the URL) and our
/// [RouteState]. Step 1 is a straight pass-through; route matching happens in
/// the delegate. Uses the modern `uri` API (no deprecated `location`).
class ModularRouteInformationParser extends RouteInformationParser<RouteState> {
  @override
  Future<RouteState> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return RouteState(uri: routeInformation.uri);
  }

  @override
  RouteInformation restoreRouteInformation(RouteState configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}
