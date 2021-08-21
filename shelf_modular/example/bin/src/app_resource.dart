import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppResource implements Resource {
  @override
  List<Route> get routes => [
        Route.get('/', start),
        Route.post('/name', getName),
      ];

  Response start(Injector i, ModularArguments args) {
    final controller = i<Controller>();
    return Response.ok('start ${controller.name}');
  }

  FutureOr<Response> getName(Request request, ModularArguments args) {
    print(request);
    return Response.ok('name: ${args.data?['n']}');
  }
}

class Controller {
  String name = 'maria';
}
