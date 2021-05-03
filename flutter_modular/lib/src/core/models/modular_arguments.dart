class ModularArguments {
  final Map<String, dynamic> params;
  final Uri? uri;
  final dynamic? data;

  const ModularArguments({this.params = const {}, this.data, this.uri});

  ModularArguments copyWith({Map<String, dynamic>? params, dynamic? data, Uri? uri}) {
    return ModularArguments(
      params: params ?? this.params,
      data: data ?? this.data,
      uri: uri ?? this.uri,
    );
  }

  String get fragment => uri?.fragment ?? '';
  Map<String, String> get queryParams => uri?.queryParameters ?? {};
  Map<String, List<String>> get queryParamsAll => uri?.queryParametersAll ?? {};

  factory ModularArguments.empty() {
    return ModularArguments();
  }
}
