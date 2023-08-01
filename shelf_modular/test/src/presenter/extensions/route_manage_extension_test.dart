import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:test/test.dart';

void main() {
  test('route manage extension', () {
    final manager = RouteManager();
    manager.get('/', () => Response.ok(''));
    manager.post('/', () => Response.ok(''));
    manager.put('/', () => Response.ok(''));
    manager.patch('/', () => Response.ok(''));
    manager.delete('/', () => Response.ok(''));
    manager.websocket('/', websocket: CustomWebsocket());
    manager.module('/', module: CustomModule());
    manager.resource(CustomResource());

    expect(manager.allRoutes.length, 8);
  });
}

class CustomResource extends Resource {
  @override
  List<Route> get routes => [];
}

class CustomModule extends Module {}

class CustomWebsocket extends WebSocketResource {
  @override
  void connect(WebSocket socket) {}

  @override
  void disconnect(WebSocket socket) {}

  @override
  void onMessage(dynamic data, WebSocket socket) {}
}
