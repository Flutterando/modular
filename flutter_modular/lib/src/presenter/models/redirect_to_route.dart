import 'package:flutter/widgets.dart';

import 'child_route.dart';

/// A route to redirect.
class RedirectRoute extends ChildRoute {
  final String to;
  RedirectRoute(
    String name, {
    required this.to,
  }) : super(name, child: (_, __) => const SizedBox());
}
