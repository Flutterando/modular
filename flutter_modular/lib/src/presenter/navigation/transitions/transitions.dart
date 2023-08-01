import 'package:flutter/widgets.dart';

import '../../../../flutter_modular.dart';

PageRouteBuilder<T> fadeInTransition<T>(
  ModularChild builder,
  Duration transitionDuration,
  RouteSettings settings,
  bool maintainState,
) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: transitionDuration,
    maintainState: maintainState,
    pageBuilder: (context, __, ___) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

PageRouteBuilder<T> rightToLeft<T>(ModularChild builder,
    Duration transitionDuration, RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.rightToLeft,
  );
}

PageRouteBuilder<T> leftToRight<T>(ModularChild builder,
    Duration transitionDuration, RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.leftToRight,
  );
}

PageRouteBuilder<T> upToDown<T>(ModularChild builder,
    Duration transitionDuration, RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.upToDown,
  );
}

PageRouteBuilder<T> downToUp<T>(ModularChild builder,
    Duration transitionDuration, RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.downToUp,
  );
}

PageRouteBuilder<T> scale<T>(ModularChild builder, Duration transitionDuration,
    RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.scale,
  );
}

PageRouteBuilder<T> rotate<T>(ModularChild builder, Duration transitionDuration,
    RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.rotate,
  );
}

PageRouteBuilder<T> size<T>(ModularChild builder, Duration transitionDuration,
    RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.size,
  );
}

PageRouteBuilder<T> rightToLeftWithFade<T>(ModularChild builder,
    Duration transitionDuration, RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.rightToLeftWithFade,
  );
}

PageRouteBuilder<T> leftToRightWithFade<T>(ModularChild builder,
    Duration transitionDuration, RouteSettings settings, bool maintainState) {
  return PageTransition<T>(
    settings: settings,
    maintainState: maintainState,
    duration: transitionDuration,
    builder: (context) {
      return builder(context);
    },
    type: PageTransitionType.leftToRightWithFade,
  );
}
