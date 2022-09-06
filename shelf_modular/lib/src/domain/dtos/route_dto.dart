import 'package:meta/meta.dart';

///Verify if the object received is equal to this object
@immutable
class RouteParmsDTO {
  ///Route [url]
  final String url;
  ///Route [arguments]
  final dynamic arguments;
  ///Route [schema]
  final String schema;

  ///[RouteParmsDTO] constructor, defines an empty [schema]
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
