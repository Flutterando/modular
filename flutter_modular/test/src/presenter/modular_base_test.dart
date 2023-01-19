import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_modular/src/domain/errors/errors.dart';
import 'package:flutter_modular/src/domain/usecases/dispose_bind.dart';
import 'package:flutter_modular/src/domain/usecases/finish_module.dart';
import 'package:flutter_modular/src/domain/usecases/get_arguments.dart';
import 'package:flutter_modular/src/domain/usecases/get_bind.dart';
import 'package:flutter_modular/src/domain/usecases/get_route.dart';
import 'package:flutter_modular/src/domain/usecases/module_ready.dart';
import 'package:flutter_modular/src/domain/usecases/reassemble_tracker.dart';
import 'package:flutter_modular/src/domain/usecases/release_scoped_binds.dart';
import 'package:flutter_modular/src/domain/usecases/set_arguments.dart';
import 'package:flutter_modular/src/domain/usecases/start_module.dart';
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:flutter_modular/src/presenter/modular_base.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_route_information_parser.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_router_delegate.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';

import '../mocks/mocks.dart';

class DisposeBindMock extends Mock implements DisposeBind {}

class ChangeNotifierMock extends Mock implements ChangeNotifier {}

class SinkMock extends Mock implements Sink {}

class GetArgumentsMock extends Mock implements GetArguments {}

class SetArgumentsMock extends Mock implements SetArguments {}

class ReassembleTrackerMock extends Mock implements ReassembleTracker {}

class FinishModuleMock extends Mock implements FinishModule {}

class GetBindMock extends Mock implements GetBind {}

class StartModuleMock extends Mock implements StartModule {}

class GetRouteMock extends Mock implements GetRoute {}

class ReleaseScopedBindsMock extends Mock implements ReleaseScopedBinds {}

class IsModuleReadyImplMock extends Mock implements IsModuleReadyImpl {}

class ParallelRouteMock extends Mock implements ParallelRoute {}

class DisposableMock extends Mock implements Disposable {}

class IModularNavigatorMock extends Mock implements IModularNavigator {}

class ModularRouteInformationParserMock extends Mock
    implements ModularRouteInformationParser {}

class ModularRouterDelegateMock extends Mock implements ModularRouterDelegate {}

class ModularErrorMock extends Mock implements ModularError {}

void main() {
  final disposeBind = DisposeBindMock();
  final getBind = GetBindMock();
  final getArguments = GetArgumentsMock();
  final setArguments = SetArgumentsMock();
  final reassembleTracker = ReassembleTrackerMock();
  final finishModule = FinishModuleMock();
  final startModule = StartModuleMock();
  final isModuleReadyImpl = IsModuleReadyImplMock();
  final modularNavigator = IModularNavigatorMock();
  final routeInformationParser = ModularRouteInformationParserMock();
  final routerDelegate = ModularRouterDelegateMock();
  late IModularBase modularBase;

  setUpAll(() {
    registerFallbackValue(const RouteParmsDTO(url: '/'));
    registerFallbackValue(ModularArguments.empty());
  });

  setUp(() {
    modularBase = ModularBase(
      reassembleTracker: reassembleTracker,
      disposeBind: disposeBind,
      finishModule: finishModule,
      getArguments: getArguments,
      getBind: getBind,
      isModuleReadyUsecase: isModuleReadyImpl,
      navigator: modularNavigator,
      startModule: startModule,
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
      setArgumentsUsecase: setArguments,
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

  test('reassemble', () {
    when(() => reassembleTracker.call()).thenReturn(right(unit));
    modularBase.reassemble();
  });

  test('get', () {
    when(() => getBind.call<String>()).thenReturn(
        right(BindEntry(bind: Bind<String>((i) => ''), value: 'modular')));
    expect(modularBase.get<String>(), 'modular');
  });

  test('getBindEntry', () {
    when(() => getBind.call<String>()).thenReturn(left(ModularErrorMock()));
    expect(modularBase.get<String>(defaultValue: 'jacob'), 'jacob');
  });

  test('getAsync', () {
    when(() => getBind.call<Future<String>>()).thenReturn(right(BindEntry(
        bind: Bind((i) async => ''), value: Future.value('modular'))));
    expect(modularBase.getAsync<String>(), completion('modular'));
    reset(getBind);
    when(() => getBind.call<Future<String>>())
        .thenReturn(left(const BindNotFoundException('')));
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

  test('setArguments', () {
    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));
    when(() => setArguments.call(any())).thenReturn(right(unit));
    modularBase.setArguments('args');
    verify(() => setArguments.call(
          any(that: predicate<ModularArguments>((it) => it.data == 'args')),
        )).called(1);
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
