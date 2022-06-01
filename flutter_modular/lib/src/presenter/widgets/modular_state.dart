import 'package:flutter/widgets.dart';

import '../../../flutter_modular.dart';

@Deprecated('''
Prefer to use `Modular.get()` instead.
''')
abstract class ModularState<TWidget extends StatefulWidget,
    TBind extends Object> extends State<TWidget> {
  final TBind _scope = Modular.get<TBind>();

  TBind get store => _scope;
  TBind get bloc => _scope;
  TBind get cubit => _scope;
  TBind get controller => _scope;

  @override
  void dispose() {
    Modular.dispose<TBind>();
    super.dispose();
  }
}
