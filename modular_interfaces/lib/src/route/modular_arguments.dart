/// Object that clusters all arguments and parameters retrieved or produced during a route search.
class ModularArguments {
  /// It retrieves parameters after consulting a dynamic route. If it is not a dynamic route the object will be an empty Map.
  /// ex: /product/:id  ->  /product/1
  /// Modular.args.params['id']; -> '1'
  final Map<String, dynamic> params;

  /// Uri of current route.
  final Uri uri;

  /// Retrieved from a direct input of arguments from the navigation system itself.
  /// ex: Modular.to.navigate('/product', arguments: Products());
  /// Modular.args.data;  -> Product();
  final dynamic data;

  const ModularArguments(
      {this.params = const {}, this.data, required this.uri});

  ModularArguments copyWith(
      {Map<String, dynamic>? params, dynamic data, Uri? uri}) {
    return ModularArguments(
      params: params ?? this.params,
      data: data ?? this.data,
      uri: uri ?? this.uri,
    );
  }

  /// The value is the empty string if there is no fragment identifier component.
  String get fragment => uri.fragment;

  /// The URI query split into a map according to the rules specified for FORM post in the HTML 4.01 specification section 17.13.4.
  /// Each key and value in the resulting map has been decoded. If there is no query the empty map is returned.
  /// Keys in the query string that have no value are mapped to the empty string. If a key occurs more than once in the query string, it is mapped to an arbitrary choice of possible value. The [queryParametersAll] getter can provide a map that maps keys to all of their values.
  /// The map and the lists it contains are unmodifiable.
  Map<String, String> get queryParams => uri.queryParameters;

  /// Returns the URI query split into a map according to the rules specified for FORM post in the HTML 4.01 specification section 17.13.4.
  /// Each key and value in the resulting map has been decoded. If there is no query the map is empty.
  /// Keys are mapped to lists of their values. If a key occurs only once, its value is a singleton list. If a key occurs with no value, the empty string is used as the value for that occurrence.
  /// The map and the lists it contains are unmodifiable.
  Map<String, List<String>> get queryParamsAll => uri.queryParametersAll;

  factory ModularArguments.empty() {
    return ModularArguments(uri: Uri.parse('/'));
  }
}
