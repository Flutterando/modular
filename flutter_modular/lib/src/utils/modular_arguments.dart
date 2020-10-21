class ModularArguments {
  final Map<String, dynamic> params;
  final dynamic data;

  ModularArguments(this.params, this.data);

  ModularArguments copy() {
    return ModularArguments(params, data);
  }
}
