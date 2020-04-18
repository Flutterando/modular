import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract class ModularStatelessWidget<T extends ChildModule>
    extends StatelessWidget with InjectWidgetMixin<T> {
  ModularStatelessWidget({Key key}) : super(key: key);
}
