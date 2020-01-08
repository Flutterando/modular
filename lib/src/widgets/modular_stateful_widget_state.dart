import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract class ModularState<TWidget extends StatefulWidget,
        TModule extends ChildModule> extends State<TWidget>
    with InjectMixinBase<TModule> {}
