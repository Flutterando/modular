import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketResource {
  FutureOr<Response> handler(Request request) async {
    final response = await webSocketHandler(_connect)(request);
    return response;
  }

  final List<WebSocket> _websockets = [];

  void onMessage(dynamic data, WebSocket socket);

  void connect(WebSocket socket);
  void disconnect(WebSocket socket);

  void _connect(WebSocketChannel socketChannel) {
    final socket = WebSocket._(socketChannel, _broadcast);

    _websockets.add(socket);
    connect(socket);
    socketChannel.stream.listen((message) {
      onMessage(message, socket);
    }, onDone: () {
      _websockets.remove(socket);
      disconnect(socket);
    });
  }

  void _broadcast(dynamic message, WebSocket currentSocket, String? room) {
    var list = _websockets.where((socket) => currentSocket != socket);
    if (room != null) {
      list = list.where((socket) => socket._rooms.contains(room));
    }

    for (var websocket in list) {
      websocket.sink.add(message);
    }
  }
}

class WebSocket {
  final WebSocketChannel _channel;
  final Set<String> _rooms = {};
  Set<String> get rooms => Set<String>.unmodifiable(_rooms);
  final void Function(dynamic message, WebSocket currentWebSocket, String? room) _broadcast;

  Stream get stream => _channel.stream;
  Sink get sink => _channel.sink;

  void joinRoom(String room) => _rooms.add(room);
  bool leaveRoom(String room) => _rooms.remove(room);

  void emit(dynamic data, {String? room}) => _broadcast(data, this, room);

  WebSocket._(this._channel, this._broadcast);
}
