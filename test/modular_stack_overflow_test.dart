import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_modular/flutter_modular.dart';

void main() {
  setUpAll(() {
    initModule(ModuleStackOverflowMock());
  });

  group("Stackoverflow", () {
    test('Error in bind', () {
      expect(
          () => Modular.get<ObjectController>(), throwsA(isA<ModularError>()));
    });

    // test('Error in route', () {
    //   expect(
    //       () => Modular.get<ObjectController>(), throwsA(isA<ModularError>()));
    // });
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
