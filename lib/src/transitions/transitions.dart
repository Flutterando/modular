import 'package:flutter/widgets.dart';

import '../../flutter_modular.dart';
import 'page_transition.dart';

PageRouteBuilder fadeInTransition(
    Widget Function(
  BuildContext,
  ModularArguments,
)
        builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (BuildContext context, __, ___) {
    return builder(context, args);
  }, transitionsBuilder: (BuildContext context, Animation animation,
      Animation secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  });
}

PageRouteBuilder noTransition(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (BuildContext context, __, ___) {
    return builder(context, args);
  });
}

PageRouteBuilder rightToLeft(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.rightToLeft);
}

PageRouteBuilder leftToRight(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.leftToRight);
}

PageRouteBuilder upToDown(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.upToDown);
}

PageRouteBuilder downToUp(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.downToUp);
}

PageRouteBuilder scale(Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args, RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.scale);
}

PageRouteBuilder rotate(Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args, RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.rotate);
}

PageRouteBuilder size(Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args, RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.size);
}

PageRouteBuilder rightToLeftWithFade(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageTransition(
    settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.rightToLeftWithFade);
}

PageRouteBuilder leftToRightWithFade(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    RouteSettings settings) {
  return PageTransition(
      settings: settings,
      builder: (context) {
        return builder(context, args);
      },
      type: PageTransitionType.leftToRightWithFade);
}
