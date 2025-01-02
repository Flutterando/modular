import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_modular/src/domain/errors/errors.dart';
import 'package:flutter_modular/src/domain/usecases/bind_module.dart';
import 'package:flutter_modular/src/domain/usecases/dispose_bind.dart';
import 'package:flutter_modular/src/domain/usecases/finish_module.dart';
import 'package:flutter_modular/src/domain/usecases/get_arguments.dart';
import 'package:flutter_modular/src/domain/usecases/get_bind.dart';
import 'package:flutter_modular/src/domain/usecases/get_route.dart';
import 'package:flutter_modular/src/domain/usecases/replace_instance.dart';
import 'package:flutter_modular/src/domain/usecases/set_arguments.dart';
import 'package:flutter_modular/src/domain/usecases/start_module.dart';
import 'package:flutter_modular/src/domain/usecases/unbind_module.dart';
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:flutter_modular/src/presenter/modular_base.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_route_information_parser.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_router_delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../mocks/mocks.dart';

class DisposeBindMock extends Mock implements DisposeBind {}

class ChangeNotifierMock extends Mock implements ChangeNotifier {}

class SinkMock extends Mock implements Sink {}

class GetArgumentsMock extends Mock implements GetArguments {}

class SetArgumentsMock extends Mock implements SetArguments {}

class FinishModuleMock extends Mock implements FinishModule {}

class GetBindMock extends Mock implements GetBind {}

class StartModuleMock extends Mock implements StartModule {}

class GetRouteMock extends Mock implements GetRoute {}

class ParallelRouteMock extends Mock implements ParallelRoute {}

class DisposableMock extends Mock implements Disposable {}

class IModularNavigatorMock extends Mock implements IModularNavigator {}

class BindModuleMock extends Mock implements BindModule {}

class UnbindModuleMock extends Mock implements UnbindModule {}

class ReplaceInstanceMock extends Mock implements ReplaceInstance {}

class ModularRouteInformationParserMock extends Mock
    implements ModularRouteInformationParser {}

class ModularRouterDelegateMock extends Mock implements ModularRouterDelegate {}

class ModularErrorMock extends Mock implements ModularError {}

void main() {
  final disposeBind = DisposeBindMock();
  final getBind = GetBindMock();
  final getArguments = GetArgumentsMock();
  final setArguments = SetArgumentsMock();
  final finishModule = FinishModuleMock();
  final startModule = StartModuleMock();
  final modularNavigator = IModularNavigatorMock();
  final routeInformationParser = ModularRouteInformationParserMock();
  final routerDelegate = ModularRouterDelegateMock();
  final replaceInstance = ReplaceInstanceMock();
  final bindModule = BindModuleMock();
  final unbindModule = UnbindModuleMock();
  late IModularBase modularBase;

  setUpAll(() {
    registerFallbackValue(const RouteParmsDTO(url: '/'));
    registerFallbackValue(ModularArguments.empty());
  });

  setUp(() {
    modularBase = ModularBase(
      routeInformationParser,
      routerDelegate,
      disposeBind,
      getArguments,
      finishModule,
      getBind,
      startModule,
      modularNavigator,
      setArguments,
      bindModule,
      unbindModule,
      replaceInstance,
    );

    reset(disposeBind);
    reset(finishModule);
    reset(getArguments);
    reset(getBind);
    reset(modularNavigator);
    reset(startModule);
    reset(routeInformationParser);
    reset(routerDelegate);
    reset(setArguments);
    reset(bindModule);
    reset(replaceInstance);
    reset(unbindModule);
  });

  test('to', () {
    expect(modularBase.to, isA<IModularNavigator>());
  });

  test('init', () {
    setPrintResolver((text) {});
    final module = ModuleMock();
    when(() => startModule.call(module)).thenReturn(const Success(unit));
    modularBase.init(module);
    verify(() => startModule.call(module));
    expect(
        () => modularBase.init(module), throwsA(isA<ModuleStartedException>()));
  });

  test('dispose', () {
    when(disposeBind.call).thenReturn(const Success(true));
    expect(modularBase.dispose(), true);
  });

  test('get', () {
    when(() => getBind.call<String>()).thenReturn(const Success('modular'));
    expect(modularBase.get<String>(), 'modular');
  });

  test('tryGet', () {
    when(() => getBind.call<String>()).thenReturn(const Success('modular'));
    when(() => getBind.call<int>())
        .thenReturn(const Failure(BindNotFoundException('')));
    expect(modularBase.tryGet<String>(), 'modular');
    expect(modularBase.tryGet<int>(), isNull);
  });

  test('bindModule', () {
    final module = ModuleMock();
    when(() => bindModule.call(module)).thenReturn(const Success(unit));
    modularBase.bindModule(module);
    verify(() => bindModule.call(module)).called(1);
  });

  test('unbindModule', () {
    when(() => unbindModule.call<ModuleMock>()).thenReturn(const Success(unit));
    modularBase.unbindModule<ModuleMock>();
    verify(() => unbindModule.call<ModuleMock>()).called(1);
  });

  test('replaceInstance', () {
    const instance = 'String';
    when(() => replaceInstance.call<String>(instance))
        .thenReturn(const Success(unit));
    modularBase.replaceInstance<String>(instance);
    verify(() => replaceInstance.call<String>(instance)).called(1);
  });

  test('destroy', () {
    when(finishModule.call).thenReturn(const Success(unit));
    modularBase.destroy();
    verify(finishModule.call).called(1);
  });

  test('setArguments', () {
    when(getArguments.call).thenReturn(Success(ModularArguments.empty()));
    when(() => setArguments.call(any())).thenReturn(const Success(unit));
    modularBase.setArguments('args');
    verify(() => setArguments.call(
          any(that: predicate<ModularArguments>((it) => it.data == 'args')),
        )).called(1);
  });
}

class MyGuard extends RouteGuard {
  final bool activate;

  // ignore: avoid_positional_boolean_parameters
  MyGuard(this.activate);

  @override
  FutureOr<bool> canActivate(String request, ParallelRoute route) {
    return activate;
  }
}
