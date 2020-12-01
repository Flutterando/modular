import 'package:flutter/widgets.dart';

import 'child_module.dart';

abstract class MainModule extends ChildModule {
  Widget get bootstrap;
}
