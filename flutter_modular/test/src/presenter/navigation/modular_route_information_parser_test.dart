// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_modular/src/domain/usecases/get_arguments.dart';
import 'package:flutter_modular/src/domain/usecases/get_route.dart';
import 'package:flutter_modular/src/domain/usecases/report_push.dart';
import 'package:flutter_modular/src/domain/usecases/set_arguments.dart';
import 'package:flutter_modular/src/infra/services/url_service/url_service.dart';
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_book.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_page.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_route_information_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:result_dart/result_dart.dart';

import '../modular_base_test.dart';

class GetRouteMock extends Mock implements GetRoute {}

class GetArgumentsMock extends Mock implements GetArguments {}

class SetArgumentsMock extends Mock implements SetArguments {}

class ReportPushMock extends Mock implements ReportPush {}

class UrlServiceMock extends Mock implements UrlService {}

class ParallelRouteFake extends Fake implements ModularRoute {}

void main() {
  late ModularRouteInformationParser parser;
  late GetRouteMock getRoute;
  late GetArgumentsMock getArguments;
  late SetArgumentsMock setArguments;
  late ReportPush reportPush;
  late UrlService urlService;

  setUp(() {
    getRoute = GetRouteMock();
    getArguments = GetArgumentsMock();
    setArguments = SetArgumentsMock();
    reportPush = ReportPushMock();
    urlService = UrlServiceMock();
    parser = ModularRouteInformationParser(
      getArguments: getArguments,
      getRoute: getRoute,
      setArguments: setArguments,
      reportPush: reportPush,
      urlService: urlService,
    );
  });

  setUpAll(() {
    registerFallbackValue(const RouteParmsDTO(url: '/test'));
    registerFallbackValue(ModularArguments.empty());
    registerFallbackValue(ParallelRouteFake());
  });

  test('selectBook one', () async {
    final routeMock = ParallelRouteMock();
    when(() => routeMock.uri).thenReturn(Uri.parse('/'));
    when(() => routeMock.parent).thenReturn('');
    when(() => routeMock.schema).thenReturn('');
    when(() => getRoute.call(any()))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getArguments.call())
        .thenReturn(Success(ModularArguments.empty()));
    when(() => routeMock.middlewares).thenReturn([Guard()]);

    when(() => reportPush(routeMock)).thenReturn(const Success(unit));

    final book = await parser.selectBook('/');
    expect(book.uri.toString(), '/');
    expect(book.chapters().first, isA<ModularPage>());
    expect(book.chapters().first.name, '/');
  });

  test('selectBook with parents', () async {
    final routeMock = ParallelRouteMock();
    when(() => routeMock.uri).thenReturn(Uri.parse('/test'));
    when(() => routeMock.parent).thenReturn('/');
    when(() => routeMock.schema).thenReturn('/');
    when(() => routeMock.middlewares).thenReturn([Guard()]);
    when(() => routeMock.copyWith(schema: any(named: 'schema')))
        .thenReturn(routeMock);

    final routeParent = ParallelRouteMock();
    when(() => routeParent.uri).thenReturn(Uri.parse('/'));
    when(() => routeParent.parent).thenReturn('');
    when(() => routeParent.schema).thenReturn('');
    when(() => routeParent.middlewares).thenReturn([Guard()]);
    when(() => routeParent.copyWith(schema: any(named: 'schema')))
        .thenReturn(routeParent);

    when(() => reportPush(routeMock)).thenReturn(const Success(unit));
    when(() => reportPush(routeParent)).thenReturn(const Success(unit));

    when(() => getRoute.call(const RouteParmsDTO(url: '/test')))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getRoute.call(const RouteParmsDTO(url: '/')))
        .thenAnswer((_) async => Success(routeParent));
    when(() => getArguments.call())
        .thenReturn(Success(ModularArguments.empty()));

    when(() => setArguments.call(any())).thenReturn(const Success(unit));

    final book = await parser.selectBook('/test');
    expect(book.uri.toString(), '/test');
    expect(book.chapters().first.name, '/');
    expect(book.chapters('/').first.name, '/test');
  });

  test('selectRoute with RedirectRoute', () async {
    final redirect = RedirectRoute('/oo', to: '/test');
    final modularArgument = ModularArguments.empty();

    final routeMock = ParallelRouteMock();
    when(() => routeMock.uri).thenReturn(Uri.parse('/test'));
    when(() => routeMock.parent).thenReturn('/');
    when(() => routeMock.schema).thenReturn('/');
    when(() => routeMock.middlewares).thenReturn([Guard()]);
    when(() => routeMock.copyWith(schema: any(named: 'schema')))
        .thenReturn(routeMock);

    final routeParent = ParallelRouteMock();
    when(() => routeParent.uri).thenReturn(Uri.parse('/'));
    when(() => routeParent.parent).thenReturn('');
    when(() => routeParent.schema).thenReturn('');
    when(() => routeParent.middlewares).thenReturn([Guard()]);
    when(() => routeParent.copyWith(schema: any(named: 'schema')))
        .thenReturn(routeParent);

    when(() => reportPush(routeMock)).thenReturn(const Success(unit));
    when(() => reportPush(routeParent)).thenReturn(const Success(unit));

    when(() => getRoute.call(const RouteParmsDTO(url: '/oo')))
        .thenAnswer((_) async => Success(redirect));
    when(() => getRoute
            .call(RouteParmsDTO(url: '/test', arguments: modularArgument.data)))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getRoute.call(const RouteParmsDTO(url: '/')))
        .thenAnswer((_) async => Success(routeParent));
    when(() => getArguments.call()).thenReturn(Success(modularArgument));

    when(() => setArguments.call(any())).thenReturn(const Success(unit));

    final book = await parser.selectBook('/oo');
    expect(book.uri.toString(), '/test');
    expect(book.chapters().first.name, '/');
    expect(book.chapters('/').first.name, '/test');
  });
  test('selectRoute with resolver route withless /', () async {
    final args = ModularArguments.empty();

    final routeMock = ParallelRouteMock();
    when(() => routeMock.uri).thenReturn(Uri.parse('/test/'));
    when(() => routeMock.parent).thenReturn('');
    when(() => routeMock.schema).thenReturn('');
    when(() => routeMock.middlewares).thenReturn([]);

    when(() => reportPush(routeMock)).thenReturn(const Success(unit));

    when(() => getRoute.call(RouteParmsDTO(url: '/test', arguments: args)))
        .thenAnswer((_) async => Failure(ModularPageException('')));
    when(() => getRoute.call(RouteParmsDTO(url: '/test/', arguments: args)))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getArguments.call()).thenReturn(Success(args));

    when(() => setArguments.call(any())).thenReturn(const Success(unit));

    final route = await parser.selectRoute('/test', arguments: args);
    expect(route.uri.toString(), '/test/');
  });

  test('restoreRouteInformation', () {
    final route = ParallelRouteMock();
    when(() => route.uri).thenReturn(Uri.parse('/test'));
    final info = parser.restoreRouteInformation(ModularBook(routes: [route]));
    expect(info.location, '/test');
  });

  test('parseRouteInformation with location null', () {
    final routeMock = ParallelRouteMock();
    when(() => routeMock.uri).thenReturn(Uri.parse('/'));
    when(() => routeMock.parent).thenReturn('');

    when(() => reportPush(routeMock)).thenReturn(const Success(unit));

    when(() => getRoute.call(any()))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getArguments.call())
        .thenReturn(Success(ModularArguments.empty()));
    when(() => routeMock.middlewares).thenReturn([Guard()]);

    expect(
        parser.parseRouteInformation(const RouteInformation(location: '/test')),
        completion(isA<ModularBook>()));
    expect(
        parser.parseRouteInformation(const RouteInformation(location: '/test')),
        completion(isA<ModularBook>()));
    expect(Guard().pre(routeMock), routeMock);
  });

  test('parseRouteInformation with location / and guard false', () {
    final routeMock = ParallelRouteMock();

    when(() => getRoute.call(any()))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getArguments.call())
        .thenReturn(Success(ModularArguments.empty()));
    when(() => routeMock.middlewares).thenReturn([Guard(false)]);
    when(() => routeMock.uri).thenReturn(Uri.parse('/'));

    expect(
        () =>
            parser.parseRouteInformation(const RouteInformation(location: '/')),
        throwsA(isA<GuardedRouteException>()));
  });

  test('parseRouteInformation with location / and middleware null', () {
    final routeMock = ParallelRouteMock();

    when(() => getRoute.call(any()))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getArguments.call())
        .thenReturn(Success(ModularArguments.empty()));
    when(() => routeMock.middlewares).thenReturn([MiddlewareNull()]);
    when(() => routeMock.uri).thenReturn(Uri.parse('/'));

    expect(
        () =>
            parser.parseRouteInformation(const RouteInformation(location: '/')),
        throwsA(isA<Exception>()));
  });

  test('throw error if path be empty', () {
    expect(() async => await parser.selectRoute(''), throwsA(isA<Exception>()));
  });

  test('selectBook with popCallback', () {
    final routeMock = ParallelRouteMock();
    when(() => reportPush(routeMock)).thenReturn(const Success(unit));
    when(() => getRoute.call(any()))
        .thenAnswer((_) async => Success(routeMock));
    when(() => getArguments.call())
        .thenReturn(Success(ModularArguments.empty()));
    when(() => routeMock.middlewares).thenReturn([]);
    when(() => routeMock.uri).thenReturn(Uri.parse('/'));
    when(() => routeMock.parent).thenReturn('');
    when(() => routeMock.copyWith(popCallback: any(named: 'popCallback')))
        .thenReturn(routeMock);
    expect(parser.selectBook('/', popCallback: (r) {}), completes);
  });
}

class Guard extends RouteGuard {
  final bool isGuard;

  Guard([this.isGuard = true]);

  @override
  FutureOr<bool> canActivate(String request, ParallelRoute route) {
    return isGuard;
  }
}

class MiddlewareNull extends Middleware {
  @override
  FutureOr<ModularRoute?> pos(ModularRoute route, dynamic data) async => null;

  @override
  FutureOr<ModularRoute?> pre(ModularRoute route) => route;
}
