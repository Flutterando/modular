import '../guards/route_guard.dart';
import 'route.dart';

/// Represents a route in the modular route tree.
/// You will be asked for a route name which should always start with '/'
/// and a widget which will be re-rendered when the route is requested.
class ChildRoute<T> extends ParallelRoute<T> {
  ChildRoute(
    String name, {
    required ModularChild child,
    CustomTransition? customTransition,
    List<ParallelRoute> children = const [],
    Duration? duration,
    TransitionType? transition,
    bool isFullscreenDialog = false,
    bool maintainState = true,
    List<RouteGuard> guards = const [],
  })  : assert(name.startsWith('/'), 'The name must always start with a /'),
        assert(
          children.where((e) => e.name == name).isEmpty,
          'Don\'t use name "/" in route\'s children when parent be "/" too',
        ),
        super(
          name: name,
          child: child,
          maintainState: maintainState,
          customTransition: customTransition,
          children: children,
          duration: duration,
          transition: transition,
          isFullscreenDialog: isFullscreenDialog,
          middlewares: guards,
        );
}
