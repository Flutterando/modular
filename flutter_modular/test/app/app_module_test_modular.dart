// import '../../lib/flutter_modular_test.dart';

import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/inject/bind.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app_module.dart';
import 'shared/ilocal_repository.dart';
import 'shared/local_mock.dart';

class InitAppModuleHelper extends IModularTest {
  final ModularTestType modularTestType;

  InitAppModuleHelper({this.modularTestType = ModularTestType.resetModules});

  @override
  List<Bind> get binds => [
        Bind<ILocalStorage>((i) => LocalMock()),
      ];

  @override
  ChildModule get module => AppModule();

  @override
  IModularTest get modulardependency => null;
}
