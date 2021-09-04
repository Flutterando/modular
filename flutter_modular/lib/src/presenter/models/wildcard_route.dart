import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_core/modular_core.dart';

import 'route.dart';

class WildcardRoute<T> extends ChildRoute<T> {
  WildcardRoute({
    required Widget Function(BuildContext, ModularArguments) child,
    TransitionType transition = TransitionType.defaultTransition,
    CustomTransition? customTransition,
    Duration duration = const Duration(milliseconds: 300),
  }) : super('/**', duration: duration, child: child, customTransition: customTransition, transition: transition);
}
