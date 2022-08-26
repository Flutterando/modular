import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/usecases/dispose_bind.dart';
import 'package:shelf_modular/src/domain/usecases/finish_module.dart';
import 'package:shelf_modular/src/domain/usecases/get_arguments.dart';
import 'package:shelf_modular/src/domain/usecases/get_bind.dart';
import 'package:shelf_modular/src/domain/usecases/get_route.dart';
import 'package:shelf_modular/src/domain/usecases/module_ready.dart';
import 'package:shelf_modular/src/domain/usecases/reassemble_tracker.dart';
import 'package:shelf_modular/src/domain/usecases/release_scoped_binds.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';
import 'package:shelf_modular/src/domain/usecases/start_module.dart';
import 'package:shelf_modular/src/presenter/errors/errors.dart';
import 'package:shelf_modular/src/presenter/modular_base.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/mocks.dart';

class DisposeBindMock extends Mock implements DisposeBind {}

class GetArgumentsMock extends Mock implements GetArguments {}

class FinishModuleMock extends Mock implements FinishModule {}

class GetBindMock extends Mock implements GetBind {}

class StartModuleMock extends Mock implements StartModule {}

class GetRouteMock extends Mock implements GetRoute {}

class ReleaseScopedBindsMock extends Mock implements ReleaseScopedBinds {}

class IsModuleReadyImplMock extends Mock implements IsModuleReadyImpl {}

class RequestMock extends Mock implements Request {}

class RouteMock extends Mock implements Route {}

class DisposableMock extends Mock implements Disposable {}

class ReportPushMock extends Mock implements ReportPush {}

class ReassembleTrackerMock extends Mock implements ReassembleTracker {}

void main() {
  final disposeBind = DisposeBindMock();
  final getBind = GetBindMock();
  final getArguments = GetArgumentsMock();
  final finishModule = FinishModuleMock();
  final startModule = StartModuleMock();
  final getRoute = GetRouteMock();
  final releaseScopedBinds = ReleaseScopedBindsMock();
  final isModuleReadyImpl = IsModuleReadyImplMock();
  final reportPush = ReportPushMock();
  final reassembleTracker = ReassembleTrackerMock();

  late IModularBase modularBase;

  setUpAll(() {
    registerFallbackValue(RouteParmsDTO(url: '/'));
  });

  setUp(() {
    modularBase = ModularBase(
        disposeBind,
        finishModule,
        getBind,
        startModule,
        isModuleReadyImpl,
        getRoute,
        getArguments,
        releaseScopedBinds,
        reportPush,
        reassembleTracker);
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

  test('start (call)', () {
    final module = RouteContextMock();
    when(() => startModule.call(module)).thenReturn(right(unit));
    final handler =
        modularBase.call(module: module, middlewares: [MyGuard(true)]);

    when(() => reassembleTracker.call()).thenReturn(right(unit));

    modularBase.reassemble();

    verify(() => startModule.call(module)).called(1);
    expect(handler, isA<FutureOr<Response> Function(Request request)>());
    expect(() => modularBase.start(module: module),
        throwsA(isA<ModuleStartedException>()));
  });

  test('handler', () async {
    final request = RequestMock();
    final response = Response.ok('test');
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));

    when(() => route.middlewares).thenReturn([]);
    when(() => route.handler).thenReturn(() => response);
    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => right(route));
    when(() => reportPush.call(route)).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 200);
  });

  test('handler with error', () async {
    final request = RequestMock();
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => route.handler).thenReturn((String v) {});
    when(() => route.middlewares).thenReturn([]);

    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getRoute.call(any())).thenThrow(Error());

    when(() => reportPush.call(route)).thenReturn(right(unit));
    when(() => releaseScopedBinds.call()).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 500);
  });
  test('handler with  hijacked request', () async {
    final request = RequestMock();
    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => request.method)
        .thenThrow(Exception('Got a response for hijacked request'));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 200);
  });

  test('handler not found because is not Route', () async {
    final request = RequestMock();
    final route = ModularRouteMock();
    when(() => route.middlewares).thenReturn([]);

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getRoute.call(any())).thenAnswer((_) async => right(route));

    when(() => reportPush.call(route)).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 404);
  });

  test('handler error handlerFunction return', () async {
    final request = RequestMock();
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => route.handler).thenReturn((String v) {});
    when(() => route.middlewares).thenReturn([]);

    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => right(route));

    when(() => reportPush.call(route)).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 500);
  });

  test('handler error in route RouteNotFoundException', () async {
    final request = RequestMock();
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => route.handler).thenReturn(() {});
    when(() => route.middlewares).thenReturn([]);

    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));
    when(() => getRoute.call(any()))
        .thenAnswer((_) async => left(RouteNotFoundException('')));

    when(() => reportPush.call(route)).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 404);
  });

  test('handler error in route (other errors)', () async {
    final request = RequestMock();
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => route.handler).thenReturn(() {});
    when(() => route.middlewares).thenReturn([]);

    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));
    when(() => getRoute.call(any()))
        .thenAnswer((_) async => left(ModuleStartedException('')));

    when(() => reportPush.call(route)).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 500);
  });

  test('handler error \'Handler not correct\'', () async {
    final request = RequestMock();
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => route.handler).thenReturn(() {});
    when(() => route.middlewares).thenReturn([]);

    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));
    when(() => getRoute.call(any()))
        .thenAnswer((_) async => left(ModuleStartedException('')));

    when(() => reportPush.call(route)).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 500);
  });

  test('handler with guard', () async {
    final request = RequestMock();
    final response = Response.ok('test');
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => route.uri).thenReturn(Uri.parse('/'));

    when(() => route.middlewares).thenReturn([MyGuard(true), MyGuard(false)]);
    when(() => route.handler).thenReturn(() => response);
    when(() => releaseScopedBinds.call()).thenReturn(right(unit));
    when(() => getArguments.call()).thenReturn(right(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => right(route));

    when(() => reportPush.call(route)).thenReturn(right(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 403);

    expect(MyGuard(true).pre(route), route);
    expect(MyGuard(true).pos(route, request), route);
  });

  test('tryJsonDecode isMultipart false', () async {
    final request = RequestMock();
    when(() => request.method).thenReturn('POST');
    when(() => request.headers).thenReturn({});
    when(() => request.readAsString())
        .thenAnswer((_) async => jsonEncode({'name': 'Jacob'}));
    final result = await (modularBase as ModularBase).tryJsonDecode(request);
    expect(result['name'], 'Jacob');
  });

  test('tryJsonDecode isMultipart false with FormatException', () async {
    final request = RequestMock();
    when(() => request.method).thenReturn('POST');
    when(() => request.headers)
        .thenReturn({'Content-Type': MediaType('image', 'png').toString()});

    when(() => request.readAsString()).thenThrow(FormatException());
    final result = await (modularBase as ModularBase).tryJsonDecode(request);
    expect(result, {});
  });

  test('tryJsonDecode isMultipart true return {}', () async {
    final request = RequestMock();
    when(() => request.method).thenReturn('POST');
    when(() => request.headers).thenReturn({
      'Content-Type':
          MediaType('multipart', 'form-data', {'boundary': 'boundary'})
              .toString()
    });
    final result = await (modularBase as ModularBase).tryJsonDecode(request);
    expect(result.isEmpty, true);
  });
}

class MyGuard extends RouteGuard {
  final bool activate;

  MyGuard(this.activate);

  @override
  FutureOr<bool> canActivate(Request request, Route route) {
    return activate;
  }
}
