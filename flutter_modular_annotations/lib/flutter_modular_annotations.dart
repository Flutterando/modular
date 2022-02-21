library flutter_modular_annotations;

class Injectable {
  final bool singleton;
  final bool lazy;
  const Injectable({this.singleton = true, this.lazy = true});
}

class _ModularParam {
  const _ModularParam();
}

const param = _ModularParam();

class _ModularQueryParam {
  const _ModularQueryParam();
}

const QueryParam = _ModularQueryParam();

class _ModularData {
  const _ModularData();
}

const data = _ModularData();

class Default {
  final dynamic defaultValue;
  const Default(this.defaultValue);
}
