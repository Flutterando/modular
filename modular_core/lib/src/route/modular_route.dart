import 'package:modular_interfaces/modular_interfaces.dart';

abstract class ModularRouteImpl implements ModularRoute {
  @override
  final String name;
  @override
  final String schema;
  @override
  final String parent;
  @override
  final List<ModularRoute> children;
  @override
  final List<Middleware> middlewares;
  @override
  final Uri uri;
  @override
  final RouteContext? context;
  @override
  final Map<Type, BindContext> bindContextEntries;
  @override
  late final ModularKey key;

  ModularRouteImpl({
    required this.name,
    this.parent = '',
    this.schema = '',
    this.context,
    this.children = const [],
    required this.uri,
    this.bindContextEntries = const {},
    this.middlewares = const [],
  }) {
    key = ModularKey(name: name, schema: schema);
  }

  @override
  ModularRoute addModule(String name, {required RouteContext module}) {
    final bindContextEntries = {module.runtimeType: module};

    return copyWith(
      name: name,
      uri: Uri.parse(name),
      bindContextEntries: bindContextEntries,
      context: module,
    );
  }

  @override
  ModularRoute copyWith({
    String? name,
    List<Middleware>? middlewares,
    List<ModularRoute>? children,
    String? parent,
    String? schema,
    RouteContext? context,
    Uri? uri,
    Map<ModularKey, ModularRoute>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  });
}
