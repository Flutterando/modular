import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract class ModularState<TWidget extends StatefulWidget, TBind>
    extends State<TWidget> {
  final controller = Modular.get<TBind>();

  @override
  void dispose() {
    super.dispose();
    Modular.dispose<TBind>();
  }
}
