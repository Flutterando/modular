import 'package:flutter/widgets.dart';

import 'package:modular_core/modular_core.dart';

import '../../../flutter_modular.dart';

/// Escape route if nothing is found in current context.
///Usually serves as a wildcard, and is called if no path matching the context is found.
///
///ATTENTION: It is strongly recommended to use one WildcardRoute per module.
class WildcardRoute<T> extends ChildRoute<T> {
  WildcardRoute({
    required Widget Function(BuildContext, ModularArguments) child,
    TransitionType transition = TransitionType.defaultTransition,
    CustomTransition? customTransition,
    Duration duration = const Duration(milliseconds: 300),
  }) : super('/**',
            duration: duration,
            child: child,
            customTransition: customTransition,
            transition: transition);
}
