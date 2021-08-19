class RouteParmsDTO {
  final String url;
  final dynamic arguments;
  final String schema;

  const RouteParmsDTO({required this.url, this.arguments, this.schema = ''});
}
