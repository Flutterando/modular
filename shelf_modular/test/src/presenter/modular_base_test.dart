import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/domain/usecases/dispose_bind.dart';
import 'package:shelf_modular/src/domain/usecases/finish_module.dart';
import 'package:shelf_modular/src/domain/usecases/get_arguments.dart';
import 'package:shelf_modular/src/domain/usecases/get_bind.dart';
import 'package:shelf_modular/src/domain/usecases/get_route.dart';
import 'package:shelf_modular/src/domain/usecases/module_ready.dart';
import 'package:shelf_modular/src/domain/usecases/release_scoped_binds.dart';
import 'package:shelf_modular/src/domain/usecases/start_module.dart';
import 'package:shelf_modular/src/presenter/modular_base.dart';

class DisposeBindMock extends Mock implements DisposeBind {}

class GetArgumentsMock extends Mock implements GetArguments {}

class FinishModuleMock extends Mock implements FinishModule {}

class GetBindMock extends Mock implements GetBind {}

class StartModuleMock extends Mock implements StartModule {}

class GetRouteMock extends Mock implements GetRoute {}

class ReleaseScopedBindsMock extends Mock implements ReleaseScopedBinds {}

class IsModuleReadyImplMock extends Mock implements IsModuleReadyImpl {}

void main() {
  final disposeBind = DisposeBindMock();
  final getArguments = GetArgumentsMock();
  final finishModule = FinishModuleMock();
  final getBind = GetBindMock();
  final startModule = StartModuleMock();
  final getRoute = GetRouteMock();
  final releaseScopedBinds = ReleaseScopedBindsMock();
  final isModuleReadyImpl = IsModuleReadyImplMock();

  final modularBase = ModularBase(disposeBind, finishModule, getBind, startModule, isModuleReadyImpl, getRoute, getArguments, releaseScopedBinds);
}
