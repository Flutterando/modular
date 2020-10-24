class ModularArguments {
  final Map<String, dynamic> params;
  final dynamic data;

  const ModularArguments({this.params, this.data});

  ModularArguments copyWith({Map<String, dynamic> params, dynamic data}) {
    return ModularArguments(
        params: params ?? this.params, data: data ?? this.data);
  }
}
