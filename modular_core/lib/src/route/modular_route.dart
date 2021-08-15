abstract class ModularRoute {
  final String name;
  final String navigatorTag;
  final List<ModularRoute> children;
  final Uri uri;

  ModularRoute({
    required this.name,
    this.navigatorTag = '/',
    this.children = const [],
    required this.uri,
  });

  String get path => uri.path;

  ModularRoute copyWith({
    String? name,
    String? navigatorTag,
    List<ModularRoute>? children,
    Uri? uri,
  });
}
