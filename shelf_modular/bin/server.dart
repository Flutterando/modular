import 'dart:io';

import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/route.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';

void main() async {
  withHotreload(() => createServer());
}

Future<HttpServer> createServer() async {
  print('Serving at http://localhost:8080');

  final pipelipe = Pipeline()
      .addMiddleware(
        logRequests(),
      )
      .addHandler(
        ModularApp(module: TestModule()),
      );

  return io.serve(pipelipe, 'localhost', 8080);
}

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.post(
          '/:name',
          (Request request, ModularArguments args) => Response.ok('modular get ${args.data?['name']}'),
        ),
      ];
}
