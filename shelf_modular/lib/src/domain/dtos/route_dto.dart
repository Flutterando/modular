class RouteParmsDTO {
  final String url;
  final dynamic arguments;
  final String schema;

  const RouteParmsDTO({required this.url, this.arguments, this.schema = ''});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteParmsDTO &&
        other.url == url &&
        other.arguments == arguments &&
        other.schema == schema;
  }

  @override
  int get hashCode => url.hashCode ^ arguments.hashCode ^ schema.hashCode;
}
