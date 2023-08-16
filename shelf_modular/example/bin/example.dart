import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular_example/src/app_module.dart';

void main(List<String> args) async {
  final handler = Modular(
    module: AppModule(),
    middlewares: [
      logRequests(),
      AuthMiddleware(),
    ],
  );

  var server = await io.serve(handler, '0.0.0.0', 4000);
  print('Serving at http://${server.address.host}:${server.port}');
}

class AuthMiddleware extends ModularMiddleware {
  @override
  Handler call(Handler handler, [ModularRoute? route]) {
    return (request) {
      return handler(request);
    };
  }
}
