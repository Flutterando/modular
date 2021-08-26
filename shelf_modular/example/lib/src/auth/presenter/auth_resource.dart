import 'dart:async';

import 'package:example/src/auth/domain/usecases/login.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'extensions/tokenization_extension.dart';

class AuthResource implements Resource {
  @override
  List<Route> get routes => [
        Route.get('/login', login),
      ];

  FutureOr<Response> login(Request request, Injector injector) async {
    final credentials = request.headers['Authorization']?.split(' ').last;

    if (credentials == null) {
      return Response.forbidden('Authorization not found');
    }

    final result = await injector.get<Login>().call(credentials: credentials);
    return result.fold((l) => Response.forbidden(l.message), (r) => Response.ok(r.toJson()));
  }
}
