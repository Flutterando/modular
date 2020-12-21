class ModularArguments {
  final Map<String, dynamic>? params;
  final Map<String, List<String>>? queryParams;
  final String? fragment;
  final dynamic? data;

  const ModularArguments({this.params, this.data, this.queryParams,this.fragment});

  ModularArguments copyWith({Map<String, dynamic>? params, dynamic? data, Map<
      String,
      List<String>>? queryParams, String? fragment}) {
    return ModularArguments(
      params: params ?? this.params,
      data: data ?? this.data,
      queryParams: queryParams ?? this.queryParams,
      fragment: fragment ?? this.fragment,
    );
  }

  factory ModularArguments.empty() {
    return ModularArguments();
  }
}
