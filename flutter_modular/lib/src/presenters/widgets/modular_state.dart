import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

import '../../../flutter_modular.dart';
import '../modular_base.dart';

abstract class ModularState<TWidget extends StatefulWidget, TBind extends Object> extends State<TWidget> {
  final TBind _store = Modular.get<TBind>();
  TBind get store => _store;

  /// deprecated: use [store]
  @deprecated
  TBind get controller => _store;

  @override
  void dispose() {
    super.dispose();
    final isDisposed = Modular.dispose<TBind>();
    if (isDisposed) {
      return;
    }

    if (_store is Disposable) {
      (_store as Disposable).dispose();
    }

    if (_store is Sink) {
      (_store as Sink).close();
    } else if (_store is ChangeNotifier) {
      (_store as ChangeNotifier).dispose();
    } else if (_store is Store) {
      (_store as Store).destroy();
    }
  }
}
