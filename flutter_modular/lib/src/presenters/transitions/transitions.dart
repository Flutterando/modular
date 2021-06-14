import 'package:flutter/widgets.dart';
import '../../core/models/modular_arguments.dart';

import '../modular_base.dart';
import 'page_transition.dart';

///Navigation Animate Fade In transition
PageRouteBuilder<T> fadeInTransition<T>(
    Widget Function(
  BuildContext,
  ModularArguments,
)
        builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: transitionDuration,
      pageBuilder: (context, __, ___) {
        return builder(context, Modular.args!);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      });
}

///Navigation Animate No Transition
PageRouteBuilder<T> noTransition<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageRouteBuilder(
      settings: settings,
      transitionDuration: transitionDuration,
      pageBuilder: (context, __, ___) {
        return builder(context, Modular.args!);
      });
}

///Navigation Animate Rigth to Left
PageRouteBuilder<T> rightToLeft<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.rightToLeft,
  );
}

///Navigation Animate Left to Rigth
PageRouteBuilder<T> leftToRight<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.leftToRight,
  );
}

///Navigation Animate Up to Down
PageRouteBuilder<T> upToDown<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.upToDown,
  );
}

///Navigation Animate Down to Up
PageRouteBuilder<T> downToUp<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.downToUp,
  );
}

///Navigation Animate Scale
PageRouteBuilder<T> scale<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.scale,
  );
}

///Navigation Animate Rotate
PageRouteBuilder<T> rotate<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.rotate,
  );
}

///Navigation Animate Size Up
PageRouteBuilder<T> size<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.size,
  );
}

///Navigation Animate Right to Left With Fade
PageRouteBuilder<T> rightToLeftWithFade<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.rightToLeftWithFade,
  );
}

///Navigation Animate Left to Right With Fade
PageRouteBuilder<T> leftToRightWithFade<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args!);
    },
    type: PageTransitionType.leftToRightWithFade,
  );
}
