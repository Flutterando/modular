import 'package:example/src/app_module.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_modular/shelf_modular.dart';

void main(List<String> args) async {
  await HotReloader.create(
    onBeforeReload: (ctx) => Modular.reassemble(),
    onAfterReload: (ctx) => print(ctx.reloadReports),
  );

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
