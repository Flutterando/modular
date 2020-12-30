import 'package:flutter/widgets.dart';

import '../modular_base.dart';

abstract class ModularState<TWidget extends StatefulWidget,
    TBind extends Object> extends State<TWidget> {
  final TBind _store = Modular.get<TBind>();
  TBind get store => _store;

  /// deprecated: use [store]
  @deprecated
  TBind get controller => _store;

  @override
  void dispose() {
    super.dispose();
    Modular.dispose<TBind>();
  }
}
