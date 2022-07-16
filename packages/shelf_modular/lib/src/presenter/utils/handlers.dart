import 'dart:async';

import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';

//less
typedef HandlerWithlessParams = FutureOr<Response> Function();
//one param
typedef Handler1 = FutureOr<Response> Function(ModularArguments args);
typedef Handler2 = FutureOr<Response> Function(Injector i);

//two params
typedef HandlerTwoParams = FutureOr<Response> Function(
    Request request, ModularArguments args);
typedef HandlerTwoParams1 = FutureOr<Response> Function(
    Request request, Injector i);
typedef HandlerTwoParams2 = FutureOr<Response> Function(
    ModularArguments args, Request request);
typedef HandlerTwoParams3 = FutureOr<Response> Function(
    ModularArguments args, Injector i);
typedef HandlerTwoParams4 = FutureOr<Response> Function(
    Injector i, ModularArguments args);
typedef HandlerTwoParams5 = FutureOr<Response> Function(
    Injector i, Request request);
//three params
typedef HandlerThreeParams = FutureOr<Response> Function(
    Request request, ModularArguments args, Injector i);
typedef HandlerThreeParams1 = FutureOr<Response> Function(
    Request request, Injector i, ModularArguments args);
typedef HandlerThreeParams2 = FutureOr<Response> Function(
    ModularArguments args, Request request, Injector i);
typedef HandlerThreeParams3 = FutureOr<Response> Function(
    ModularArguments args, Injector i, Request request);
typedef HandlerThreeParams4 = FutureOr<Response> Function(
    Injector i, ModularArguments args, Request request);
typedef HandlerThreeParams5 = FutureOr<Response> Function(
    Injector i, Request request, ModularArguments args);

FutureOr<Response>? applyHandler(Function fn,
    {required Request request,
    required ModularArguments arguments,
    required Injector injector}) {
  //less
  if (fn is HandlerWithlessParams) {
    return fn();
  } else if (fn is Handler) {
    return fn(request);
  } else if (fn is Handler1) {
    return fn(arguments);
  } else if (fn is Handler2) {
    return fn(injector);
  } else if (fn is HandlerTwoParams) {
    return fn(request, arguments);
  } else if (fn is HandlerTwoParams1) {
    return fn(request, injector);
  } else if (fn is HandlerTwoParams2) {
    return fn(arguments, request);
  } else if (fn is HandlerTwoParams3) {
    return fn(arguments, injector);
  } else if (fn is HandlerTwoParams4) {
    return fn(injector, arguments);
  } else if (fn is HandlerTwoParams5) {
    return fn(injector, request);
  } else if (fn is HandlerThreeParams) {
    return fn(request, arguments, injector);
  } else if (fn is HandlerThreeParams1) {
    return fn(request, injector, arguments);
  } else if (fn is HandlerThreeParams2) {
    return fn(arguments, request, injector);
  } else if (fn is HandlerThreeParams3) {
    return fn(arguments, injector, request);
  } else if (fn is HandlerThreeParams4) {
    return fn(injector, arguments, request);
  } else if (fn is HandlerThreeParams5) {
    return fn(injector, request, arguments);
  } else {
    return null;
  }
}
