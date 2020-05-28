// import '../../lib/flutter_modular_test.dart';

import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/inject/bind.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app_module.dart';
import 'shared/ILocalRepository.dart';
import 'shared/local_mock.dart';

class InitAppModuleHelper extends IModularTest {
  final ModularTestType modularTestType;

  InitAppModuleHelper({this.modularTestType: ModularTestType.resetModule});

  @override
  List<Bind> binds() {
    return [
      Bind<ILocalStorage>((i) => LocalMock()),
    ];
  }

  @override
  ChildModule module() {
    return AppModule();
  }

  @override
  IModularTest modulardependency() {
    return null;
  }

  
}
