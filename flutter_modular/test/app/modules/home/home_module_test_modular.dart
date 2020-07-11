// import '../../lib/flutter_modular_test.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';

import '../../app_module_test_modular.dart';
import 'home_module.dart';

class InitHomeModuleHelper extends IModularTest {
  final ModularTestType modularTestType;

  InitHomeModuleHelper({this.modularTestType = ModularTestType.resetModules});

  @override
  List<Bind> get binds => [];

  @override
  ChildModule get module => HomeModule();

  @override
  IModularTest get modulardependency => InitAppModuleHelper();
}
