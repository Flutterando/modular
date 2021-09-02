import 'package:flutter/widgets.dart';

import '../../presenters/modular_route_impl.dart';
import '../interfaces/modular_route.dart';

class RedirectRoute extends ModularRouteImpl {
  final String to;
  RedirectRoute(
    String routerName, {
    required this.to,
  }) : super(
          routerName,
          routerOutlet: [],
          duration: const Duration(milliseconds: 300),
          child: (_, __) => Container(),
          children: const [],
          transition: TransitionType.defaultTransition,
        );
}
