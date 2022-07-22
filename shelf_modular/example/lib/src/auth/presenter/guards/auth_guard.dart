import 'dart:async';
import 'dart:convert';

import 'package:example/src/auth/domain/usecases/check_token.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthGuard extends RouteGuard {
  @override
  FutureOr<bool> canActivate(Request request, Route route) async {
    final accessToken = request.headers['Authorization']?.split(' ').last;
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }
    final result =
        await Modular.get<CheckToken>().call(accessToken: accessToken);
    return result.fold((l) => false, (r) => true);
  }
}

class AuthGuard2 extends RouteGuard {
  @override
  FutureOr<bool> canActivate(Request request, Route route) async {
    final accessToken = request.headers['Authorization']?.split(' ').last;
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    return accessToken == '1234';
  }
}

class AuthGuard3 extends ModularMiddleware {
  @override
  Handler call(Handler handler, [ModularRoute? route]) {
    return (request) {
      final accessToken = request.headers['Authorization']?.split(' ').last;
      if (accessToken == null || accessToken.isEmpty || accessToken != '1234') {
        return Response.forbidden(jsonEncode({'error': 'Not authorized'}));
      }
      return handler(request);
    };
  }
}
