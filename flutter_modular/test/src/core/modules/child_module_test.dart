import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/core/errors/errors.dart';
import 'package:flutter_modular/src/core/models/bind.dart';
import 'package:flutter_modular/src/core/interfaces/module.dart';
import 'package:flutter_test/flutter_test.dart';

class Module2 extends Module {
  @override
  final List<Bind<Object>> binds = [
    Bind.instance<double>(1.0, export: true),
  ];
}

class ModuleMock extends Module {
  @override
  final List<Module> imports = [
    Module2(),
  ];

  @override
  final List<Bind> binds = [
    Bind((i) => "Test"),
    Bind.instance<int>(1),
    Bind((i) => true, isLazy: false),
    Bind((i) => StreamController(), isLazy: false),
    Bind((i) => ValueNotifier<int>(0), isLazy: false),
  ];

  @override
  final List<ModularRoute> routes = [];
}

main() {
  var module = ModuleMock();

  setUp(() {
    module = ModuleMock();
  });

  test('should return the same objects in list of binds', () {
    final list1 = module.binds;
    final list2 = module.binds;
    expect(list1, equals(list2));
  });

  test('should return imported bind', () {
    expect(module.getBind<double>(typesInRequest: []), equals(1.0));
  });

  test('should change binds into new list of bind', () {
    module.changeBinds([
      Bind((i) => "Test"),
      Bind((i) => true),
      Bind((i) => 0.0),
    ]);
    expect(module.binds.length, 3);
  });

  test('should get bind', () {
    expect(module.getBind<String>(typesInRequest: []), equals('Test'));
    expect(module.getBind<bool>(typesInRequest: []), equals(true));
    expect(module.getBind<int>(typesInRequest: []), equals(1));
  });

  test('should return null if not found bind', () {
    expect(module.getBind<List>(typesInRequest: []), null);
  });

  test('should throw exception when exist value over in the injection search', () {
    expect(() => module.getBind<bool>(typesInRequest: [bool]), throwsA(isA<ModularError>()));
  });

  test('should Create a instance of all binds isn\'t lazy Loaded', () {
    module.instance([]);
    expect(module.getBind<bool>(typesInRequest: [bool]), equals(true));
  });

  test('should remove bind', () {
    module.instance([]);
    expect(module.getBind<bool>(typesInRequest: [bool]), equals(true));

    module.remove<bool>();
    expect(() => module.getBind<bool>(typesInRequest: [bool]), throwsA(isA<ModularError>()));

    //Stream
    expect(module.getBind<StreamController>(typesInRequest: [StreamController]), isA<StreamController>());

    module.remove<StreamController>();
    expect(() => module.getBind<StreamController>(typesInRequest: [StreamController]), throwsA(isA<ModularError>()));

    //ChangeNotifier
    expect(module.getBind<ChangeNotifier>(typesInRequest: [ChangeNotifier]), isA<ChangeNotifier>());

    module.remove<ChangeNotifier>();
    expect(() => module.getBind<ChangeNotifier>(typesInRequest: [ChangeNotifier]), throwsA(isA<ModularError>()));
  });

  test('should clean all injections', () {
    module.instance([]);
    expect(module.getBind<bool>(typesInRequest: [bool]), equals(true));
    expect(module.getBind<StreamController>(typesInRequest: [StreamController]), isA<StreamController>());
    expect(module.getBind<ChangeNotifier>(typesInRequest: [ChangeNotifier]), isA<ChangeNotifier>());

    module.cleanInjects();

    expect(() => module.getBind<bool>(typesInRequest: [bool]), throwsA(isA<ModularError>()));

    expect(() => module.getBind<StreamController>(typesInRequest: [StreamController]), throwsA(isA<ModularError>()));

    expect(() => module.getBind<ChangeNotifier>(typesInRequest: [ChangeNotifier]), throwsA(isA<ModularError>()));
  });

  test('should instance when container in list of singletons', () {
    module.instance([true]);
    expect(() => module.getBind<bool>(typesInRequest: [bool]), throwsA(isA<ModularError>()));
  });
}
