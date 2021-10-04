import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_core/modular_core.dart';

import 'page_transition.dart';

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
    maintainState: true,
    pageBuilder: (context, __, ___) {
      return builder(context, Modular.args);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

PageRouteBuilder<T> rightToLeft<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.rightToLeft,
  );
}

PageRouteBuilder<T> leftToRight<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.leftToRight,
  );
}

PageRouteBuilder<T> upToDown<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.upToDown,
  );
}

PageRouteBuilder<T> downToUp<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.downToUp,
  );
}

PageRouteBuilder<T> scale<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.scale,
  );
}

PageRouteBuilder<T> rotate<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.rotate,
  );
}

PageRouteBuilder<T> size<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.size,
  );
}

PageRouteBuilder<T> rightToLeftWithFade<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.rightToLeftWithFade,
  );
}

PageRouteBuilder<T> leftToRightWithFade<T>(
    Widget Function(BuildContext, ModularArguments) builder,
    Duration transitionDuration,
    RouteSettings settings) {
  return PageTransition<T>(
    settings: settings,
    duration: transitionDuration,
    builder: (context) {
      return builder(context, Modular.args);
    },
    type: PageTransitionType.leftToRightWithFade,
  );
}
