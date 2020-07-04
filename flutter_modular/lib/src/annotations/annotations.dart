class Injectable {
  final bool singleton;
  final bool lazy;
  const Injectable({this.singleton = true, this.lazy = true});
}

class _ModularParam {
  const _ModularParam();
}

const Param = _ModularParam();

class _ModularData {
  const _ModularData();
}

const Data = _ModularData();
