import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:flutter_modular/src/presenter/guards/route_guard.dart';
import 'package:flutter_modular/src/presenter/models/modular_navigator.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_modular/src/domain/errors/errors.dart';
import 'package:flutter_modular/src/domain/usecases/dispose_bind.dart';
import 'package:flutter_modular/src/domain/usecases/finish_module.dart';
import 'package:flutter_modular/src/domain/usecases/get_arguments.dart';
import 'package:flutter_modular/src/domain/usecases/get_bind.dart';
import 'package:flutter_modular/src/domain/usecases/get_route.dart';
import 'package:flutter_modular/src/domain/usecases/module_ready.dart';
import 'package:flutter_modular/src/domain/usecases/release_scoped_binds.dart';
import 'package:flutter_modular/src/domain/usecases/start_module.dart';
import 'package:flutter_modular/src/presenter/modular_base.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:triple/triple.dart';

import '../mocks/mocks.dart';

class DisposeBindMock extends Mock implements DisposeBind {}

class ChangeNotifierMock extends Mock implements ChangeNotifier {}

class SinkMock extends Mock implements Sink {}

class StoreMock extends Mock implements Store {}

class GetArgumentsMock extends Mock implements GetArguments {}

class FinishModuleMock extends Mock implements FinishModule {}

class GetBindMock extends Mock implements GetBind {}

class StartModuleMock extends Mock implements StartModule {}

class GetRouteMock extends Mock implements GetRoute {}

class ReleaseScopedBindsMock extends Mock implements ReleaseScopedBinds {}

class IsModuleReadyImplMock extends Mock implements IsModuleReadyImpl {}

class ParallelRouteMock extends Mock implements ParallelRoute {}

class DisposableMock extends Mock implements Disposable {}

class IModularNavigatorMock extends Mock implements IModularNavigator {}

void main() {
  final disposeBind = DisposeBindMock();
  final getBind = GetBindMock();
  final getArguments = GetArgumentsMock();
  final finishModule = FinishModuleMock();
  final startModule = StartModuleMock();
  final isModuleReadyImpl = IsModuleReadyImplMock();
  final modularNavigator = IModularNavigatorMock();
  late IModularBase modularBase;

  setUpAll(() {
    registerFallbackValue(RouteParmsDTO(url: '/'));
  });

  setUp(() {
    modularBase = ModularBase(
      disposeBind: disposeBind,
      finishModule: finishModule,
      getArguments: getArguments,
      getBind: getBind,
      isModuleReadyUsecase: isModuleReadyImpl,
      navigator: modularNavigator,
      startModule: startModule,
    );
  });

  test('debugPrintModular', () {
    modularBase.debugPrintModular('text');
    expect((modularBase as ModularBase).flags.isDebug, true);
    (modularBase as ModularBase).flags.isDebug = false;
    modularBase.debugPrintModular('text');
    expect((modularBase as ModularBase).flags.isDebug, false);
  });

  test('to', () {
    expect(modularBase.to, isA<IModularNavigator>());
  });

  test('init', () {
    final module = ModuleMock();
    when(() => startModule.call(module)).thenReturn(right(unit));
    modularBase.init(module);
    verify(() => startModule.call(module));
    expect(
        () => modularBase.init(module), throwsA(isA<ModuleStartedException>()));
  });

  test('dispose', () {
    when(() => disposeBind.call()).thenReturn(right(true));
    expect(modularBase.dispose(), true);
  });

  test('get', () {
    when(() => getBind.call<String>()).thenReturn(right('modular'));
    expect(modularBase.get<String>(), 'modular');
  });

  test('getAsync', () {
    when(() => getBind.call<Future<String>>())
        .thenReturn(right(Future.value('modular')));
    expect(modularBase.getAsync<String>(), completion('modular'));
    reset(getBind);
    when(() => getBind.call<Future<String>>())
        .thenReturn(left(BindNotFoundException('')));
    expect(modularBase.getAsync<String>(defaultValue: 'changed'),
        completion('changed'));
  });

  test('isModuleReady', () {
    when(() => isModuleReadyImpl.call()).thenAnswer((_) async => right(true));
    expect(modularBase.isModuleReady(), completes);
  });

  test('destroy', () {
    when(() => finishModule.call()).thenReturn(right(unit));
    modularBase.destroy();
    verify(() => finishModule.call()).called(1);
  });

  test('disposeBindFunction', () {
    final changeNotifierMock = ChangeNotifierMock();
    final sinkMock = SinkMock();
    final disposableMock = DisposableMock();
    final storeMock = StoreMock();
    when(() => storeMock.destroy()).thenAnswer((_) async {});
    (modularBase as ModularBase).disposeBindFunction(disposableMock);
    (modularBase as ModularBase).disposeBindFunction(changeNotifierMock);
    (modularBase as ModularBase).disposeBindFunction(sinkMock);
    (modularBase as ModularBase).disposeBindFunction(storeMock);
    verify(() => disposableMock.dispose()).called(1);
    verify(() => sinkMock.close()).called(1);
    verify(() => changeNotifierMock.dispose()).called(1);
    verify(() => storeMock.destroy()).called(1);
  });
}

class MyGuard extends RouteGuard {
  final bool activate;

  MyGuard(this.activate);

  @override
  FutureOr<bool> canActivate(String request, ParallelRoute route) {
    return activate;
  }
}
