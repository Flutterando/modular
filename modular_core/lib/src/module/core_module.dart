import 'dart:async';

import 'package:auto_injector/auto_injector.dart';

typedef Injector = AutoInjector;

abstract class Module {
  List<Module> get imports;

  List<Bind> get binds;

  List<Bind> get exportedBinds;

  List<ModularRoute> get routes;
}

typedef DisposeCallback<T extends Object> = void Function(T value);
typedef SelectorCallback<T extends Object> = dynamic Function(T value);

abstract class Bind<T extends Object> {
  final Function constructor;

  ///Called in module`s dispose.
  final DisposeCallback<T>? onDispose;

  /// Generate reactive object
  final SelectorCallback<T>? selector;

  ///export bind for others modules
  ///This bind can only be accessed when imported by a module.
  final bool export;

  Bind(
    this.constructor, {
    this.export = false,
    this.onDispose,
    this.selector,
  });

  static Bind<T> singleton<T extends Object>(
    Function constructor,
    DisposeCallback<T>? onDispose,
    SelectorCallback<T>? selector,
  ) {
    return SingletonBind<T>(
      constructor,
      onDispose: onDispose,
      selector: selector,
    );
  }

  static Bind<T> lazySingleton<T extends Object>(
    Function constructor,
    DisposeCallback<T>? onDispose,
    SelectorCallback<T>? selector,
  ) {
    return LazySingletonBind<T>(
      constructor,
      onDispose: onDispose,
      selector: selector,
    );
  }

  static Bind<T> factory<T extends Object>(
    Function constructor,
    DisposeCallback<T>? onDispose,
    SelectorCallback<T>? selector,
  ) {
    return FactoryBind<T>(
      constructor,
      onDispose: onDispose,
      selector: selector,
    );
  }

  static Bind<T> instance<T extends Object>(
    T instance,
    DisposeCallback<T>? onDispose,
    SelectorCallback<T>? selector,
  ) {
    return InstanceBind<T>(
      instance,
      onDispose: onDispose,
      selector: selector,
    );
  }
}

class SingletonBind<T extends Object> extends Bind<T> {
  SingletonBind(super.constructor, {super.onDispose, super.selector});
}

class LazySingletonBind<T extends Object> extends Bind<T> {
  LazySingletonBind(super.constructor, {super.onDispose, super.selector});
}

class FactoryBind<T extends Object> extends Bind<T> {
  FactoryBind(super.constructor, {super.onDispose, super.selector});
}

class InstanceBind<T extends Object> extends Bind<T> {
  InstanceBind(T instance, {super.onDispose, super.selector})
      : super(() => instance);
}

abstract class ModularRoute {
  /// name of route
  final String name;

  /// schema of route
  /// default is ''
  final String schema;

  /// Add children to this route that can be retrieved through the parent route
  final List<ModularRoute> children;

  /// Adds middleware that will be shared among your children.
  final List<Middleware> middlewares;

  /// Key that references the route in the RouteContext tree.
  late final ModularKey key;

  late final Uri uri;

  /// RouteContext belonging to the route.
  Module? module;

  /// guard your parent's path
  final String parent;

  /// Contains a list of all BindContexts that will need to be active when this route is active.
  late final Map<Type, Module> innerModules;

  /// Create a new Route by adding a RouteContext to the context.
  ModularRoute addModule(String name, {required Module module});

  ModularRoute(
    this.name, {
    this.schema = '',
    this.parent = '',
    this.module,
    this.children = const [],
    this.middlewares = const [],
  }) {
    innerModules = {};
    uri = Uri.parse(name);
    key = ModularKey(name: name, schema: schema);
  }

  ModularRoute copyWith({
    String? name,
    String? schema,
    List<ModularRoute>? children,
    List<Middleware>? middlewares,
    Map<Type, Module> innerModules,
    Uri? uri,
    String? parent,
    Module? module,
  });
}

class ModularKey {
  final String schema;
  final String name;

  const ModularKey({required this.name, this.schema = ''});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModularKey && other.schema == schema && other.name == name;
  }

  @override
  int get hashCode => schema.hashCode ^ name.hashCode;

  ModularKey copyWith({
    String? schema,
    String? name,
  }) {
    return ModularKey(
      schema: schema ?? this.schema,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'ModularKey(schema: $schema, name: $name)';
}

/// Object that intercepts a route request.
abstract class Middleware<T> {
  /// Method called as soon as route is found and before settings.
  FutureOr<ModularRoute?> pre(ModularRoute route);

  /// Method called as soon as route is found and after settings.
  FutureOr<ModularRoute?> pos(ModularRoute route, T data);
}
