import 'package:flutter/widgets.dart';

import '../modular_base.dart';

abstract class ModularState<TWidget extends StatefulWidget, TBind extends Object>
    extends State<TWidget> {
  final TBind? controller = Modular.get<TBind>();

  @override
  void dispose() {
    super.dispose();
    Modular.dispose<TBind>();
  }
}
