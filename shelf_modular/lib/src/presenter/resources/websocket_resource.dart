import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

///Abstract class [WebSocketResource]
///act and an interface
abstract class WebSocketResource {
  ///Returns a [webSocketHandler] with a [request]
  FutureOr<Response> handler(Request request) {
    return webSocketHandler(connectSocket)(request);
  }

  final List<WebSocket> _websockets = [];

  ///Receives a message [data] and a [WebSocket]
  ///Handles the message
  void onMessage(dynamic data, WebSocket socket);

  ///Stabilish connection, receives a [WebSocket]
  void connect(WebSocket socket);

  ///Resposible for disconnectt, receives a [WebSocket]

  void disconnect(WebSocket socket);

  ///Connects a socket, disconnects it when done
  @visibleForTesting
  void connectSocket(WebSocketChannel socketChannel) {
    final socket = WebSocket._(socketChannel, _broadcast);

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

  void _broadcast(
    dynamic message,
    WebSocket currentSocket,
    Iterable<String> rooms,
  ) {
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

///Creates a websocket
class WebSocket {
  final WebSocketChannel _channel;
  final Set<String> _enteredRooms = {};
  late final Stream _stream = _channel.stream.asBroadcastStream();

  ///Collection of objects type [String]
  Set<String> get enteredRooms => Set<String>.unmodifiable(_enteredRooms);
  final void Function(
    dynamic message,
    WebSocket currentWebSocket,
    Iterable<String> room,
  ) _broadcast;

  ///tag for the [WebSocket]
  dynamic tag;

  ///[Stream] instance
  Stream get stream => _stream;

  ///[Sink] instance

  Sink get sink => _channel.sink;

  ///Adds a [String] in the [Set] of strings
  void joinRoom(String room) => _enteredRooms.add(room);

  ///Removes a [String] from the [Set] of strings
  bool leaveRoom(String room) => _enteredRooms.remove(room);

  ///Broadcast the [data], websocket and [rooms]
  void emit(dynamic data, [Iterable<String> rooms = const []]) =>
      _broadcast(data, this, rooms);

  ///Broadcasts the [data] to a [Set] of strings
  void emitToRooms(dynamic data) => _broadcast(data, this, _enteredRooms);

  WebSocket._(this._channel, this._broadcast);
}
