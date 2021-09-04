import 'package:modular_interfaces/modular_interfaces.dart';

abstract class ModularRouteImpl implements ModularRoute {
  final String name;
  final String schema;
  final String parent;
  final List<ModularRoute> children;
  final List<Middleware> middlewares;
  final Uri uri;
  final RouteContext? context;
  final Map<Type, BindContext> bindContextEntries;
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
    this.key = ModularKey(name: name, schema: schema);
  }

  ModularRoute addModule(String name, {required RouteContext module}) {
    final bindContextEntries = {module.runtimeType: module};

    return copyWith(
      name: name,
      uri: Uri.parse(name),
      bindContextEntries: bindContextEntries,
      context: module,
    );
  }

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
