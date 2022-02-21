import '../../../flutter_modular.dart';
import 'package:modular_core/modular_core.dart';

/// This route represents a cluster of routes from another module that will be concatenated to the context of the parent module.
class ModuleRoute<T> extends ParallelRoute<T> {
  ModuleRoute._start({
    ModularChild? child,
    required String name,
    void Function(dynamic)? popCallback,
    String parent = '',
    String schema = '',
    RouteContext? context,
    TransitionType? transition,
    CustomTransition? customTransition,
    Duration? duration,
    List<ModularRoute> children = const [],
    List<Middleware> middlewares = const [],
    Uri? uri,
    Map<Type, BindContext> bindContextEntries = const {},
  })  : assert(!name.contains('/:'),
            'ModuleRoute should not contain dynamic route'),
        super(
          name: name,
          child: child,
          popCallback: popCallback,
          transition: transition,
          customTransition: customTransition,
          duration: duration,
          parent: parent,
          schema: schema,
          children: children,
          context: context,
          middlewares: middlewares,
          uri: uri ?? Uri.parse('/'),
          bindContextEntries: bindContextEntries,
        );

  factory ModuleRoute(
    String name, {
    required Module module,
    TransitionType? transition,
    CustomTransition? customTransition,
    Duration? duration,
    List<RouteGuard> guards = const [],
  }) {
    final route = ModuleRoute<T>._start(
        name: name,
        middlewares: guards,
        transition: transition,
        customTransition: customTransition,
        duration: duration);
    return route.addModule(name, module: module) as ModuleRoute<T>;
  }

  @override
  ModuleRoute<T> copyWith({
    ModularChild? child,
    TransitionType? transition,
    CustomTransition? customTransition,
    Duration? duration,
    RouteContext? context,
    String? name,
    String? schema,
    void Function(dynamic)? popCallback,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  }) {
    return ModuleRoute<T>._start(
      child: child ?? this.child,
      transition: transition ?? this.transition,
      customTransition: customTransition ?? this.customTransition,
      duration: duration ?? this.duration,
      name: name ?? this.name,
      schema: schema ?? this.schema,
      popCallback: popCallback ?? this.popCallback,
      middlewares: middlewares ?? this.middlewares,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      uri: uri ?? this.uri,
      context: context ?? this.context,
      bindContextEntries: bindContextEntries ?? this.bindContextEntries,
    );
  }
}
