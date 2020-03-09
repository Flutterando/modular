import 'package:flutter/widgets.dart';

enum PageTransitionType {
  fade,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
}

class PageTransition<T> extends PageRouteBuilder<T> {
  final Widget Function(BuildContext context) builder;
  final PageTransitionType type;
  final Curve curve;
  final Alignment alignment;
  final Duration duration;

  PageTransition({
    Key key,
    @required this.builder,
    @required this.type,
    this.curve = Curves.easeInOut,
    this.alignment,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings settings,
  }) : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return builder(context);
          },
          transitionDuration: duration,
          settings: settings,
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            switch (type) {
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
                break;
              case PageTransitionType.rightToLeft:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(-1.0, 0.0),
                    ).animate(CurvedAnimation(
                        parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
                break;
              case PageTransitionType.leftToRight:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(1.0, 0.0),
                    ).animate(CurvedAnimation(
                        parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
                break;
              case PageTransitionType.upToDown:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(0.0, -1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(0.0, 1.0),
                    ).animate(CurvedAnimation(
                        parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
                break;
              case PageTransitionType.downToUp:
                return SlideTransition(
                  transformHitTests: false,
                  position: Tween<Offset>(
                    begin: Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(0.0, -1.0),
                    ).animate(CurvedAnimation(
                        parent: secondaryAnimation, curve: curve)),
                    child: child,
                  ),
                );
                break;
              case PageTransitionType.scale:
                return ScaleTransition(
                  alignment: alignment,
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      0.00,
                      0.50,
                      curve: curve,
                    ),
                  ),
                  child: child,
                );
                break;
              case PageTransitionType.rotate:
                return RotationTransition(
                  alignment: alignment,
                  turns: CurvedAnimation(parent: animation, curve: curve),
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: CurvedAnimation(parent: animation, curve: curve),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
                break;
              case PageTransitionType.size:
                return Align(
                  alignment: Alignment.center,
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                    child: child,
                  ),
                );
                break;
              case PageTransitionType.rightToLeftWithFade:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: curve),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset.zero,
                        end: Offset(-1.0, 0.0),
                      ).animate(CurvedAnimation(
                          parent: secondaryAnimation, curve: curve)),
                      child: child,
                    ),
                  ),
                );
                break;
              case PageTransitionType.leftToRightWithFade:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: curve),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset.zero,
                        end: Offset(1.0, 0.0),
                      ).animate(CurvedAnimation(
                          parent: secondaryAnimation, curve: curve)),
                      child: child,
                    ),
                  ),
                );
                break;
              default:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
            }
          },
        );
}
