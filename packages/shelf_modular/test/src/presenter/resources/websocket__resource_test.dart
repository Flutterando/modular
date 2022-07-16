import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:shelf_modular/src/presenter/resources/websocket_resource.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../modular_base_test.dart';

class WebSocketChannelMock extends Mock implements WebSocketChannel {}

class WebSocketSinkMock extends Fake implements WebSocketSink {
  final Sink sink;

  WebSocketSinkMock(this.sink);

  @override
  void add(data) => sink.add(data);
}

void main() {
  test('handle', () {
    final request = RequestMock();
    final resource = MyWebsocketResource();
    expect(
        () async => await resource.handler(request), throwsA(isA<TypeError>()));
  });

  test('connectSocket', () async {
    final controllerGeneral = StreamController.broadcast();
    final controllerResourceSocket = StreamController.broadcast();
    final resource = MyWebsocketResource(controllerResourceSocket);
    final channel = WebSocketChannelMock();

    final sinkMock = WebSocketSinkMock(controllerGeneral.sink);

    when(() => channel.stream).thenAnswer((_) => controllerGeneral.stream);
    when(() => channel.sink).thenReturn(sinkMock);
    expect(controllerResourceSocket.stream,
        emitsInOrder([isA<WebSocket>(), isA<WebSocket>(), isA<WebSocket>()]));

    //start
    resource.connectSocket(channel);
    resource.connectSocket(channel);
    controllerGeneral.sink.add('message');
    await controllerGeneral.sink.close();

    expect(resource.message, equals('message'));
  });
}

class MyWebsocketResource extends WebSocketResource {
  final StreamController? controllerResourceSocket;

  String message = '';

  MyWebsocketResource([this.controllerResourceSocket]);

  @override
  void connect(WebSocket socket) {
    controllerResourceSocket?.add(socket);
    socket.emit('teste');
    socket.sink.add('teste');
    if (socket.enteredRooms.isNotEmpty) {
      throw 'should be empty';
    }

    socket.joinRoom('room');
    socket.emitToRooms('teste');
    if (socket.enteredRooms.isEmpty) {
      throw 'should be not empty';
    }
    socket.leaveRoom('room');
  }

  @override
  void disconnect(WebSocket socket) {
    controllerResourceSocket?.add(socket);
  }

  @override
  void onMessage(data, WebSocket socket) {
    message = data;
    controllerResourceSocket?.add(socket);
  }
}
