import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_modular/shelf_modular.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(Modular(module: AppModule()));

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.scoped((i) => Controller()),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.get('/', (shelf.Request request, ModularArguments args) => shelf.Response.ok('ok get')),
        Route.post('/', (shelf.Request request) => shelf.Response.ok('ok post')),
        Route.resource('/controller', resource: MyResource()),
      ];
}

class MyResource implements Resource {
  @override
  List<Route> get routes => [
        Route.get('/', getPosts),
        Route.get('/products', getProducts),
      ];

  FutureOr<Response> getPosts(shelf.Request request, Injector i) {
    final controller = i<Controller>();
    return shelf.Response.ok('ok ${controller.name}');
  }

  FutureOr<Response> getProducts(shelf.Request request) => shelf.Response.ok('ok product');
}

class Controller {
  final String name = 'Jacob';

  Controller() {
    print('it is controller!!');
  }
}
