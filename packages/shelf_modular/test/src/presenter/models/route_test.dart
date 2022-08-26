import 'package:shelf_modular/shelf_modular.dart';
import 'package:test/test.dart';

void main() {
  test('route get', () {
    final route = Route.get('/', () {});
    expect(route.name, '/');
    expect(route.schema, 'GET');
  });

  test('route post', () {
    final route = Route.post('/', () {});
    expect(route.name, '/');
    expect(route.schema, 'POST');
  });
  test('route delete', () {
    final route = Route.delete('/', () {});
    expect(route.name, '/');
    expect(route.schema, 'DELETE');
  });
  test('route PATCH', () {
    final route = Route.path('/', () {});
    expect(route.name, '/');
    expect(route.schema, 'PATCH');
  });
  test('route PUT', () {
    final route = Route.put('/', () {});
    expect(route.name, '/');
    expect(route.schema, 'PUT');
  });
  test('route module', () {
    final route = Route.module('/', module: MyModule());
    expect(route.name, '/');
  });
  test('route resource', () {
    final route = Route.resource(MyResource());
    expect(route.name, '/');
  });

  test('route resource', () {
    final route = Route.websocket('/', websocket: MyWebsocketResource());
    expect(route.name, '/');
  });
  test('route copyWith', () {
    final route = Route.resource(MyResource()).copyWith();
    expect(route.name, '/');
  });
}

class MyModule extends Module {}

class MyResource extends Resource {
  @override
  List<Route> get routes => [];
}

class MyWebsocketResource extends WebSocketResource {
  @override
  void connect(WebSocket socket) {}

  @override
  void disconnect(WebSocket socket) {}

  @override
  void onMessage(data, WebSocket socket) {}
}
