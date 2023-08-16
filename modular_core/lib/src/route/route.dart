part of '../../modular_core.dart';

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

  /// Module belonging to the route.
  Module? module;

  /// guard your parent's path
  final String parent;

  /// Contains a list of all BindContexts that will need
  /// to be active when this route is active.
  final Map<Type, Module> innerModules;

  /// Create a new Route by adding a RouteContext to the context.
  ModularRoute addModule(String name, {required Module module});

  ModularRoute(
    this.name, {
    this.schema = '',
    this.parent = '',
    this.module,
    required this.uri,
    this.innerModules = const {},
    this.children = const [],
    this.middlewares = const [],
  }) {
    key = ModularKey(name: name, schema: schema);
  }

  ModularRoute copyWith({
    String? name,
    String? schema,
    List<ModularRoute>? children,
    List<Middleware>? middlewares,
    Map<Type, Module>? innerModules,
    Uri? uri,
    String? parent,
    Module? module,
  });

  ModularRoute addParent(ModularRoute parent) {
    final newName = '${parent.name}$name'.replaceFirst('//', '/');
    return copyWith(
      name: newName,
      parent: parent.name,
      middlewares: [
        ...parent.middlewares,
        ...middlewares,
      ],
      innerModules: {
        ...parent.innerModules,
        ...innerModules,
      },
    );
  }
}

@immutable
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
    return ModularKey(schema: schema ?? this.schema, name: name ?? this.name);
  }
}
