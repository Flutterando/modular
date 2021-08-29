import 'package:example/src/app_module.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main(List<String> args) async {
  var handlerWebSocket = webSocketHandler((webSocket) {
    webSocket.stream.listen((message) {
      webSocket.sink.add('echo $message');
    });
  });
  final handler = shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(Modular(module: AppModule()));
  // final handler = shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(Modular(module: AppModule()));

  var server = await io.serve(handler, '0.0.0.0', 4000);
  print('Serving at http://${server.address.host}:${server.port}');
}
