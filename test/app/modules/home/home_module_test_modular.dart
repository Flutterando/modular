// import '../../lib/flutter_modular_test.dart';

import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/inject/bind.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../app_module_test_modular.dart';
import 'home_module.dart';



class InitHomeModuleHelper extends IModularTest {
  final ModularTestType modularTestType;

  InitHomeModuleHelper({this.modularTestType: ModularTestType.resetModule});

  @override
  List<Bind> binds() {
    return [
    ];
  }

  @override
  ChildModule module() {
    return HomeModule();
  }

  @override
  IModularTest modulardependency() {
    return InitAppModuleHelper();
  }

  
}
