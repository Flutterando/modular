// import '../../lib/flutter_modular_test.dart';

import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/inject/bind.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../app_module_test_modular.dart';
import 'product_module.dart';



class InitProductModuleHelper extends IModularTest {
  final ModularTestType modularTestType;

  InitProductModuleHelper({this.modularTestType: ModularTestType.resetModules});

  @override
  List<Bind> binds() {
    return [
    ];
  }

  @override
  ChildModule module() {
    return ProductModule();
  }

  @override
  IModularTest modulardependency() {
    return InitAppModuleHelper();
  }

  
}
