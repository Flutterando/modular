import 'package:modular_core/src/di/bind_context.dart';

abstract class Route {
  final String name;
  final String tag;
  final Route? parent;
  late final List<Route> children;
  final Uri uri;
  final Map<Type, BindContext> bindContextEntries;
  late final Map<String, Route> routeMap;

  Route({
    required this.name,
    this.tag = '',
    List<Route> children = const [],
    this.parent,
    required this.uri,
    this.bindContextEntries = const {},
    Map<String, Route>? routeMap,
  }) {
    if (routeMap == null) {
      this.routeMap = {};
      this.children = children
          .map(
            (e) => e.copyWith(
              parent: this,
              tag: uri.path,
              bindContextEntries: Map.from(bindContextEntries)..addAll(e.bindContextEntries),
            ),
          )
          .toList();
      this.routeMap[name] = this;
      for (var child in this.children) {
        this.routeMap[child.name] = child;
      }
    } else {
      this.routeMap = routeMap;
    }
  }

  String get path => uri.path;

  Route copyWith({
    String? name,
    String? tag,
    List<Route>? children,
    Route? parent,
    Uri? uri,
    Map<String, Route>? routeMap,
    Map<Type, BindContext>? bindContextEntries,
  });
}
