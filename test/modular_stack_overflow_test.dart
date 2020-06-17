import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    initModule(ModuleStackOverflowMock());
    initModule(ModuleStackOverflowMockNotError());
  });

  group("Stackoverflow", () {
    test('Error in bind', () {
      expect(Modular.get, throwsA(isA<ModularError>()));
    });

    test('Not Error', () {
      expect(
          Modular.get<HomeController>(
              module: 'ModuleStackOverflowMockNotError'),
          isA<HomeController>());
    });
  });
}

class ModuleStackOverflowMock extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => ObjectController(i.get<ObjectRepository>())),
        Bind((i) => ObjectRepository(i.get<ObjectController>())),
      ];

  @override
  List<Router> get routers => [];
}

class ObjectController {
  final ObjectRepository repo;

  ObjectController(this.repo);
}

class ObjectRepository {
  final ObjectController controller;

  ObjectRepository(this.controller);
}

class ModuleStackOverflowMockNotError extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => ObjectRepository01()),
        Bind((i) => ObjectRepository02(i.get<ObjectRepository01>())),
        Bind((i) => ObjectRepository03(
            i.get<ObjectRepository01>(), i.get<ObjectRepository02>())),
        Bind((i) => HomeController(i.get<ObjectRepository03>())),
      ];

  @override
  List<Router> get routers => [];
}

class HomeController {
  final ObjectRepository03 repo;

  HomeController(this.repo);
}

class ObjectRepository01 {}

class ObjectRepository02 {
  final ObjectRepository01 controller;

  ObjectRepository02(this.controller);
}

class ObjectRepository03 {
  final ObjectRepository01 controller1;
  final ObjectRepository02 controller2;

  ObjectRepository03(this.controller1, this.controller2);
}
