import 'package:example/src/auth/domain/usecases/check_token.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/src/request.dart';
import 'dart:async';

import 'package:shelf_modular/shelf_modular.dart';

class AuthGuard extends RouteGuard {
  @override
  FutureOr<bool> canActivate(Request request, Route route) async {
    final accessToken = request.headers['Authorization']?.split(' ').last;
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }
    final result = await Modular.get<CheckToken>().call(accessToken: accessToken);
    return result.fold((l) => false, (r) => true);
  }
}
