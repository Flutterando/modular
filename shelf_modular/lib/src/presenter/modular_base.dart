// ignore_for_file: noop_primitive_operations, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';
import 'package:modular_core/modular_core.dart' hide Middleware;
import 'package:result_dart/functions.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/usecases/dispose_bind.dart';
import 'package:shelf_modular/src/domain/usecases/finish_module.dart';
import 'package:shelf_modular/src/domain/usecases/get_arguments.dart';
import 'package:shelf_modular/src/domain/usecases/get_bind.dart';
import 'package:shelf_modular/src/domain/usecases/get_route.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';
import 'package:shelf_modular/src/domain/usecases/start_module.dart';
import 'package:shelf_modular/src/shelf_modular_module.dart';

import 'errors/errors.dart';
import 'handlers/handlers.dart';

abstract class IModularBase {
  /// Finishes all trees(BindContext and RouteContext).
  void destroy();

  /// Responsible for starting the app.
  /// It should only be called once, but it should be the first method to
  /// be called before a route or bind lookup.
  /// [module]: Start initial module.
  /// [middlewares]: List of Shelf middlewares.
  Handler call({
    required Module module,
    List<Middleware> middlewares = const [],
  });

  /// Responsible for starting the app.
  /// It should only be called once, but it should be the first method to
  /// be called before a route or bind lookup.
  Handler start({required Module module});

  /// Request an instance by [Type]
  B get<B extends Object>();

  /// Request an instance by [Type]
  /// Returning null if not found instance
  B? tryGet<B extends Object>();

  /// Dispose a bind by [Type]
  bool dispose<B extends Object>();
}

class ModularBase implements IModularBase {
  final DisposeBind disposeBind;
  final GetArguments getArguments;
  final FinishModule finishModule;
  final GetBind getBind;
  final StartModule startModule;
  final GetRoute getRoute;
  final ReportPush reportPush;

  bool _moduleHasBeenStarted = false;

  ModularBase(
    this.disposeBind,
    this.finishModule,
    this.getBind,
    this.startModule,
    this.getRoute,
    this.getArguments,
    this.reportPush,
  );

  @override
  bool dispose<B extends Object>() {
    return disposeBind<B>().getOrElse((_) => false);
  }

  @override
  B get<B extends Object>() {
    return getBind<B>().getOrThrow();
  }

  @override
  B? tryGet<B extends Object>() {
    return getBind<B>().getOrNull();
  }

  @override
  void destroy() => finishModule();

  @override
  Handler call({
    required Module module,
    List<Middleware> middlewares = const [],
  }) {
    if (!_moduleHasBeenStarted) {
      startModule(module).getOrThrow();
      print('${module.runtimeType} started!');
      _moduleHasBeenStarted = true;

      setPrintResolver(print);
      var pipeline = const Pipeline();
      for (final middleware in middlewares) {
        pipeline = pipeline.addMiddleware(middleware);
      }

      return pipeline.addHandler(handler);
    } else {
      throw ModuleStartedException(
        'Module ${module.runtimeType} is already started',
      );
    }
  }

  @override
  Handler start({required Module module}) => call(module: module);

  @visibleForTesting
  FutureOr<Response> handler(Request request) async {
    try {
      final data = await tryJsonDecode(request);
      final params = RouteParmsDTO(
        url: '/${request.url.toString()}',
        schema: request.method,
        arguments: data,
      );
      return getRoute //
          .call(params)
          .map((route) => _routeSuccess(route, request))
          .mapError(_routeError)
          .fold(identity, identity);
    } on Exception catch (e, s) {
      if (e.toString().contains(
            'Exception: Got a response for hijacked request',
          )) {
        return Response.ok('');
      } else {
        print(e.toString());
        print('STACK TRACE \n $s');
        return Response.internalServerError(body: '${e.toString()}/n$s');
      }
    }
  }

  FutureOr<Response> _routeSuccess(ModularRoute? route, Request request) async {
    final middlewares = route?.middlewares ?? [];
    var pipeline = const Pipeline();

    for (final middleware in middlewares) {
      if (middleware is ModularMiddleware) {
        pipeline = pipeline.addMiddleware(
          (innerHandler) => middleware(innerHandler, route),
        );
      }
    }

    if (route is! Route) {
      return Response.notFound('');
    }
    reportPush(route);

    final routeHandler = route.handler!;

    return pipeline.addHandler((request) async {
      final response = await applyHandler(
        routeHandler,
        request: request,
        arguments: getArguments().getOrElse((left) => ModularArguments.empty()),
        injector: injector<AutoInjector>(),
      );

      if (response != null) {
        return response;
      } else {
        return Response.internalServerError(body: 'Handler not correct');
      }
    })(request);
  }

  FutureOr<Response> _routeError(ModularError error) {
    if (error is RouteNotFoundException) {
      return Response.notFound(error.message);
    }

    return Response.internalServerError(body: error.toString());
  }

  @visibleForTesting
  Future<Map> tryJsonDecode(Request request) async {
    if (request.method == 'GET') return {};

    if (!_isMultipart(request)) {
      try {
        final data = await request.readAsString();
        return jsonDecode(data);
      } on FormatException catch (e) {
        print(e);
        return {};
      }
    }

    return {};
  }

  bool _isMultipart(Request request) {
    return _extractMultipartBoundary(request) != null;
  }

  String? _extractMultipartBoundary(Request request) {
    if (!request.headers.containsKey('Content-Type')) return null;

    final contentType = MediaType.parse(request.headers['Content-Type']!);
    if (contentType.type != 'multipart') return null;

    return contentType.parameters['boundary'];
  }
}
