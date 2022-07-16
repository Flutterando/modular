import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/usecases/dispose_bind.dart';
import 'package:shelf_modular/src/domain/usecases/finish_module.dart';
import 'package:shelf_modular/src/domain/usecases/get_arguments.dart';
import 'package:shelf_modular/src/domain/usecases/get_bind.dart';
import 'package:shelf_modular/src/domain/usecases/get_route.dart';
import 'package:shelf_modular/src/domain/usecases/module_ready.dart';
import 'package:shelf_modular/src/domain/usecases/release_scoped_binds.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';
import 'package:shelf_modular/src/domain/usecases/start_module.dart';
import 'package:shelf_modular/src/shelf_modular_module.dart';
import 'errors/errors.dart';
import 'models/module.dart';
import 'utils/handlers.dart';
import 'models/route.dart';
import 'package:meta/meta.dart';

abstract class IModularBase {
  /// Finishes all trees(BindContext and RouteContext).
  void destroy();

  /// checks if all asynchronous binds are ready to be used synchronously of all BindContext of Tree.
  Future<void> isModuleReady<M extends Module>();

  /// Responsible for starting the app.
  /// It should only be called once, but it should be the first method to be called before a route or bind lookup.
  Handler call({required RouteContext module});

  /// Responsible for starting the app.
  /// It should only be called once, but it should be the first method to be called before a route or bind lookup.
  Handler start({required RouteContext module});

  /// Request an async instance by [Type]
  Future<B> getAsync<B extends Object>({B? defaultValue});

  /// Request an instance by [Type]
  B get<B extends Object>({
    B? defaultValue,
  });

  /// Dispose a [Bind] by [Type]
  bool dispose<B extends Object>();
}

class ModularBase implements IModularBase {
  final DisposeBind disposeBind;
  final GetArguments getArguments;
  final FinishModule finishModule;
  final GetBind getBind;
  final StartModule startModule;
  final GetRoute getRoute;
  final ReleaseScopedBinds releaseScopedBinds;
  final IsModuleReadyImpl isModuleReadyImpl;
  final ReportPush reportPush;

  bool _moduleHasBeenStarted = false;

  ModularBase(
      this.disposeBind,
      this.finishModule,
      this.getBind,
      this.startModule,
      this.isModuleReadyImpl,
      this.getRoute,
      this.getArguments,
      this.releaseScopedBinds,
      this.reportPush);

  @override
  bool dispose<B extends Object>() =>
      disposeBind<B>().getOrElse((left) => false);

  @override
  B get<B extends Object>({B? defaultValue}) {
    return getBind<B>().getOrElse((left) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw left;
    });
  }

  @override
  Future<B> getAsync<B extends Object>({B? defaultValue}) {
    return getBind<Future<B>>().getOrElse((left) {
      if (defaultValue != null) {
        return Future.value(defaultValue);
      }
      throw left;
    });
  }

  @override
  Future<void> isModuleReady<M extends Module>() => isModuleReadyImpl<M>();

  @override
  void destroy() => finishModule();

  @visibleForTesting
  void disposeBindFunction(bindValue) {
    if (bindValue is Disposable) {
      bindValue.dispose();
    }
  }

  @override
  Handler call({required RouteContext module}) {
    if (!_moduleHasBeenStarted) {
      startModule(module)
          .fold((l) => throw l, (r) => print('${module.runtimeType} started!'));
      _moduleHasBeenStarted = true;

      setDisposeResolver(disposeBindFunction);

      setPrintResolver(print);
      return handler;
    } else {
      throw ModuleStartedException(
          'Module ${module.runtimeType} is already started');
    }
  }

  @override
  Handler start({required RouteContext module}) => call(module: module);

  @visibleForTesting
  FutureOr<Response> handler(Request request) async {
    Response response;
    try {
      final data = await tryJsonDecode(request);
      final params = RouteParmsDTO(
          url: '/${request.url.toString()}',
          schema: request.method,
          arguments: data);
      final result = await getRoute.call(params);
      response = await result.fold<FutureOr<Response>>(
          _routeError, (r) => _routeSuccess(r, request));
    } on Exception catch (e) {
      if (e
          .toString()
          .contains('Exception: Got a response for hijacked request')) {
        response = Response.ok('');
      } else {
        rethrow;
      }
    } catch (e, s) {
      print(e.toString());
      print('STACK TRACE \n $s');
      response = Response.internalServerError(body: '${e.toString()}/n$s');
    }
    releaseScopedBinds();
    return response;
  }

  FutureOr<Response> _routeSuccess(ModularRoute? route, Request request) async {
    try {
      for (var middleware in route!.middlewares) {
        route = await middleware.pos(route!, request);
        if (route == null) {
          break;
        }
      }

      if (route is Route) {
        reportPush(route);

        final response = applyHandler(
          route.handler!,
          request: request,
          arguments:
              getArguments().getOrElse((left) => ModularArguments.empty()),
          injector: injector<Injector>(),
        );
        if (response != null) {
          return response;
        } else {
          return Response.internalServerError(body: 'Handler not correct');
        }
      }
      return Response.notFound('');
    } on GuardedRouteException catch (e) {
      return Response.forbidden(jsonEncode({'error': e.toString()}));
    }
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
    // else {
    //   final params = <String, dynamic>{};
    //   await for (final part in parts(request)) {
    //     if (!part.headers.containsKey('content-disposition')) {
    //       continue;
    //     }
    //     final header = HeaderValue.parse(part.headers['content-disposition']!);
    //     final key = header.parameters['name'];
    //     if (key == null) {
    //       continue;
    //     }
    //     if (!header.parameters.containsKey('filename')) {
    //       final value = await utf8.decodeStream(part);
    //       params[key] = value;
    //     } else {
    //       final file = File(header.parameters['filename']!);
    //       final fileSink = file.openWrite();
    //       await part.pipe(fileSink);
    //       await fileSink.close();
    //       params[key] = file;
    //     }
    //   }
    //   return params;
    // }
  }

  bool _isMultipart(Request request) =>
      _extractMultipartBoundary(request) != null;

  String? _extractMultipartBoundary(Request request) {
    if (!request.headers.containsKey('Content-Type')) return null;

    final contentType = MediaType.parse(request.headers['Content-Type']!);
    if (contentType.type != 'multipart') return null;

    return contentType.parameters['boundary'];
  }

  // Stream<MimeMultipart> parts(Request request) {
  //   final boundary = _extractMultipartBoundary(request)!;
  //   return MimeMultipartTransformer(boundary).bind(request.read()).map((part) => _CaseInsensitiveMultipart(part));
  // }
}

// class _CaseInsensitiveMultipart extends MimeMultipart {
//   final MimeMultipart _inner;
//   Map<String, String>? _normalizedHeaders;

//   _CaseInsensitiveMultipart(this._inner);

//   @override
//   Map<String, String> get headers {
//     return _normalizedHeaders ??= CaseInsensitiveMap.from(_inner.headers);
//   }

//   @override
//   StreamSubscription<List<int>> listen(void Function(List<int> data)? onData, {void Function()? onDone, Function? onError, bool? cancelOnError}) {
//     return _inner.listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
//   }
// }
