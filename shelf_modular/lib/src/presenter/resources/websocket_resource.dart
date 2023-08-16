import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketResource {
  FutureOr<Response> handler(Request request) {
    return webSocketHandler(connectSocket)(request);
  }

  final List<WebSocket> _websockets = [];

  void onMessage(dynamic data, WebSocket socket);

  void connect(WebSocket socket);
  void disconnect(WebSocket socket);

  @visibleForTesting
  void connectSocket(WebSocketChannel socketChannel) {
    final socket = WebSocket._(socketChannel, broadcast);

    _websockets.add(socket);
    connect(socket);
    socket.stream.listen(
      (message) {
        onMessage(message, socket);
      },
      onDone: () {
        _websockets.remove(socket);
        disconnect(socket);
      },
    );
  }

  void broadcast(
    dynamic message, {
    WebSocket? currentSocket,
    Iterable<String> rooms = const [],
  }) {
    for (final room in rooms.isEmpty ? [''] : rooms) {
      var list = _websockets.where((socket) => currentSocket != socket);
      if (room.isNotEmpty) {
        list = list.where((socket) => socket._enteredRooms.contains(room));
      }

      for (final websocket in list) {
        websocket.sink.add(message);
      }
    }
  }
}

class WebSocket {
  final WebSocketChannel _channel;
  final Set<String> _enteredRooms = {};
  late final Stream _stream = _channel.stream.asBroadcastStream();
  Set<String> get enteredRooms => Set<String>.unmodifiable(_enteredRooms);
  final void Function(
    dynamic message, {
    WebSocket? currentSocket,
    Iterable<String> rooms,
  }) _broadcast;
  dynamic tag;

  Stream get stream => _stream;
  Sink get sink => _channel.sink;

  void joinRoom(String room) => _enteredRooms.add(room);
  bool leaveRoom(String room) => _enteredRooms.remove(room);

  void emit(dynamic data, [Iterable<String> rooms = const []]) =>
      _broadcast(data, currentSocket: this, rooms: rooms);
  void emitToRooms(dynamic data) =>
      _broadcast(data, currentSocket: this, rooms: _enteredRooms);

  WebSocket._(this._channel, this._broadcast);
}
