import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/src/presenter/utils/handlers.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

class RequestMock extends Mock implements Request {}

void main() {
  FutureOr<Response>? _applyHandler(Function fn) {
    return applyHandler(
      fn,
      request: RequestMock(),
      arguments: ModularArguments.empty(),
      injector: InjectorMock(),
    );
  }

  test('HandlerWithlessParams', () {
    expect(_applyHandler(() => Response.ok('')), isNotNull);
  });

  test('Handle', () {
    expect(_applyHandler((request) => Response.ok('')), isNotNull);
  });

  test('Handler1', () {
    expect(
        _applyHandler((ModularArguments args) => Response.ok('')), isNotNull);
  });

  test('Handler2', () {
    expect(_applyHandler((Injector injector) => Response.ok('')), isNotNull);
  });

  test('HandlerTwoParams', () {
    expect(
        _applyHandler(
            (Request request, ModularArguments args) => Response.ok('')),
        isNotNull);
  });

  test('HandlerTwoParams1', () {
    expect(
        _applyHandler(
            (Request request, Injector<dynamic> i) => Response.ok('')),
        isNotNull);
  });

  test('HandlerTwoParams2', () {
    expect(
        _applyHandler(
            (ModularArguments args, Request request) => Response.ok('')),
        isNotNull);
  });
  test('HandlerTwoParams3', () {
    expect(
        _applyHandler(
            (ModularArguments args, Injector<dynamic> i) => Response.ok('')),
        isNotNull);
  });

  test('HandlerTwoParams4', () {
    expect(
        _applyHandler(
            (Injector<dynamic> i, ModularArguments args) => Response.ok('')),
        isNotNull);
  });

  test('HandlerTwoParams5', () {
    expect(
        _applyHandler(
            (Injector<dynamic> i, Request request) => Response.ok('')),
        isNotNull);
  });

  test('HandlerThreeParams', () {
    expect(
        _applyHandler(
            (Request request, ModularArguments args, Injector<dynamic> i) =>
                Response.ok('')),
        isNotNull);
  });

  test('HandlerThreeParams1', () {
    expect(
        _applyHandler(
            (Request request, Injector<dynamic> i, ModularArguments args) =>
                Response.ok('')),
        isNotNull);
  });
  test('HandlerThreeParams2', () {
    expect(
        _applyHandler(
            (ModularArguments args, Request request, Injector<dynamic> i) =>
                Response.ok('')),
        isNotNull);
  });

  test('HandlerThreeParams3', () {
    expect(
        _applyHandler(
            (ModularArguments args, Injector<dynamic> i, Request request) =>
                Response.ok('')),
        isNotNull);
  });

  test('HandlerThreeParams4', () {
    expect(
        _applyHandler(
            (Injector<dynamic> i, ModularArguments args, Request request) =>
                Response.ok('')),
        isNotNull);
  });
  test('HandlerThreeParams5', () {
    expect(
        _applyHandler(
            (Injector<dynamic> i, Request request, ModularArguments args) =>
                Response.ok('')),
        isNotNull);
  });
}
