import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/presenter/errors/errors.dart';
import 'package:shelf_modular/src/presenter/modular_base.dart';
import 'package:test/test.dart';

import '../mocks/mocks.dart';

void main() {
  final disposeBind = DisposeBindMock();
  final getBind = GetBindMock();
  final getArguments = GetArgumentsMock();
  final finishModule = FinishModuleMock();
  final startModule = StartModuleMock();
  final getRoute = GetRouteMock();

  final reportPush = ReportPushMock();

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
      getRoute,
      getArguments,
      reportPush,
    );
  });

  test('dispose', () {
    when(() => disposeBind.call()).thenReturn(Success(true));
    expect(modularBase.dispose(), true);
  });

  test('get', () {
    when(() => getBind.call<String>()).thenReturn(Success('modular'));
    expect(modularBase.get<String>(), 'modular');
  });

  test('destroy', () {
    when(() => finishModule.call()).thenReturn(Success(unit));
    modularBase.destroy();
    verify(() => finishModule.call()).called(1);
  });

  test('start (call)', () {
    final module = ModuleMock();
    when(() => startModule.call(module)).thenReturn(Success(unit));
    final handler = modularBase.call(module: module, middlewares: [MyGuard(true)]);

    verify(() => startModule.call(module)).called(1);
    expect(handler, isA<FutureOr<Response> Function(Request request)>);
    expect(() => modularBase.start(module: module), throwsA(isA<ModuleStartedException>()));
  });

  test('handler', () async {
    final request = RequestMock();
    final response = Response.ok('test');
    final route = RouteMock();

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));

    when(() => route.middlewares).thenReturn([]);
    when(() => route.handler).thenReturn(() => response);
    when(() => getArguments.call()).thenReturn(Success(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => Success(route));
    when(() => reportPush.call(route)).thenReturn(Success(unit));

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

    when(() => getArguments.call()).thenReturn(Success(ModularArguments.empty()));

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => getRoute.call(any())).thenThrow(Exception());

    when(() => reportPush.call(route)).thenReturn(Success(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 500);
  });
  test('handler with  hijacked request', () async {
    final request = RequestMock();
    when(() => request.method).thenThrow(Exception('Got a response for hijacked request'));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 200);
  });

  test('handler not found because is not Route', () async {
    final request = RequestMock();
    final route = ModularRouteMock();
    when(() => route.middlewares).thenReturn([]);

    when(() => request.method).thenReturn('GET');
    when(() => request.url).thenReturn(Uri.parse(''));
    when(() => getRoute.call(any())).thenAnswer((_) async => Success(route));

    when(() => reportPush.call(route)).thenReturn(Success(unit));

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

    when(() => getArguments.call()).thenReturn(Success(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => Success(route));

    when(() => reportPush.call(route)).thenReturn(Success(unit));

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

    when(() => getArguments.call()).thenReturn(Success(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => Failure(RouteNotFoundException('')));

    when(() => reportPush.call(route)).thenReturn(Success(unit));

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

    when(() => getArguments.call()).thenReturn(Success(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => Failure(ModuleStartedException('')));

    when(() => reportPush.call(route)).thenReturn(Success(unit));

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

    when(() => getArguments.call()).thenReturn(Success(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => Failure(ModuleStartedException('')));

    when(() => reportPush.call(route)).thenReturn(Success(unit));

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
    when(() => getArguments.call()).thenReturn(Success(ModularArguments.empty()));
    when(() => getRoute.call(any())).thenAnswer((_) async => Success(route));

    when(() => reportPush.call(route)).thenReturn(Success(unit));

    final result = await (modularBase as ModularBase).handler(request);
    expect(result.statusCode, 403);

    expect(MyGuard(true).pre(route), route);
    expect(MyGuard(true).pos(route, request), route);
  });

  test('tryJsonDecode isMultipart false', () async {
    final request = RequestMock();
    when(() => request.method).thenReturn('POST');
    when(() => request.headers).thenReturn({});
    when(() => request.readAsString()).thenAnswer((_) async => jsonEncode({'name': 'Jacob'}));
    final result = await (modularBase as ModularBase).tryJsonDecode(request);
    expect(result['name'], 'Jacob');
  });

  test('tryJsonDecode isMultipart false with FormatException', () async {
    final request = RequestMock();
    when(() => request.method).thenReturn('POST');
    when(() => request.headers).thenReturn({'Content-Type': MediaType('image', 'png').toString()});

    when(() => request.readAsString()).thenThrow(FormatException());
    final result = await (modularBase as ModularBase).tryJsonDecode(request);
    expect(result, {});
  });

  test('tryJsonDecode isMultipart true return {}', () async {
    final request = RequestMock();
    when(() => request.method).thenReturn('POST');
    when(() => request.headers).thenReturn({
      'Content-Type': MediaType('multipart', 'form-data', {'boundary': 'boundary'}).toString()
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
